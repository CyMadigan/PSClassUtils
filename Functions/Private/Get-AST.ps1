Function Get-AST {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $true)
        ]
        $InputObject,

    [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $true
    )]
    [Alias('FullName')]
    [System.IO.FileInfo]$Path
    )
    
    begin {

        function sortast {
            [CmdletBinding()]
            PAram(

                $RawAST
            )

            $Type = $AST.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
            [System.Management.Automation.Language.StatementAst[]] $Enums = @()
            $Enums = $type | ? {$_.IsEnum -eq $true}
            [System.Management.Automation.Language.StatementAst[]] $Classes = @()
            $Classes = $type | ? {$_.IsClass -eq $true}
            
            return [ASTDocument]::New($Classes,$Enums)

        }

    }
    
    process {


        if($Path){
            foreach($p in $PAth){

                [System.IO.FileInfo]$File = (Resolve-Path -Path $p).Path
                $AST = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)

                sortast -RawAST $AST
            }
        }else{
        
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($InputObject, [ref]$null, [ref]$Null)
                sortast -RawAST $AST
        
        }

        


    }
    
    end {
    }
}

$Arr = Get-AST -Path "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1","C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\05\BenGelens_CWindowsContainer.ps1"

$r = gc "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\05\BenGelens_CWindowsContainer.ps1"

#Get-AST -InputObject $r

#$r | Get-AST

"C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1","C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1" | get-ast