import-module pester
start-sleep -seconds 2

$moduleName = "$($env:APPVEYOR_PROJECT_NAME)"
Get-Module $moduleName

#Pester Tests
write-verbose "invoking pester"
#$TestFiles = (Get-ChildItem -Path .\ -Recurse  | ?{$_.name.EndsWith(".ps1") -and $_.name -notmatch ".tests." -and $_.name -notmatch "build" -and $_.name -notmatch "Example"}).Fullname


$res = Invoke-Pester -Path "$($env:APPVEYOR_BUILD_FOLDER)\Tests" -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru #-CodeCoverage $TestFiles

#Uploading Testresults to Appveyor
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))


if ($res.FailedCount -gt 0 -or $res.PassedCount -eq 0) { 
    throw "$($res.FailedCount) tests failed - $($res.PassedCount) successfully passed"
};


    
if($res.FailedCount -eq 0 -and $env:APPVEYOR_REPO_BRANCH -eq "master"){
    import-module $ModuleName -force
    $GalleryVersion = (Find-Module $ModuleName).version
    $LocalVersion = (get-module $ModuleName).version.ToString()
    if($Localversion -le $GalleryVersion){
        Write-host "[$($env:APPVEYOR_REPO_BRANCH)] PsClassUtils version $($localversion)  is identical with the one on the gallery. No upload done."
    }Else{

    publish-module -Name $ModuleName -NuGetApiKey $Env:PSgalleryKey;
    write-host "[$($env:APPVEYOR_REPO_BRANCH)] Module deployed to the psgallery" -foregroundcolor green;
    }
}else{
    write-host "[$($env:APPVEYOR_REPO_BRANCH)]Module not deployed to the psgallery" -foregroundcolor Yellow;
}