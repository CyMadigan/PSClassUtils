Function Get-CUAst {
    <#
    .SYNOPSIS
    Helper function to get AST Class and Enum data from files or strings.

    .DESCRIPTION
    Get-CUAst returns an object of type [ASTDocument] which contains Classes, Enums, and the source file of the items.

    .PARAMETER Path
    
    Must point to a file. If it contains powershell Classes or Enums, it will output an object.

    .PARAMETER InputObject

    Accepts a single or array of strings. If it contains powershell Classes or Enums, it will output an object.

    .OUTPUTS
    An array of ASTDocuments

    [ASTDocument[]]

    .EXAMPLE
    
    Get-CUAst -Path "c:\Scripts\JeffHicks_StarShipModule.ps1"

    #Returns

    Classes                            Enums                         Source
    -------                            -----                         ------
    {mystarshIp, Cruiser, Dreadnought} {ShipClass, ShipSpeed, Cloak} JeffHicks_StarShipModule.ps1

    .EXAMPLE
    #It is possible to pass an array of paths as well.

    $Arr = Get-CUAst -Path "C:\Scripts\JeffHicks_StarShipModule.ps1","C:\Scripts\BenGelens_CWindowsContainer.ps1"
    $Arr

    #Returns
    Classes                            Enums                               Source
    -------                            -----                               ------
    {mystarshIp, Cruiser, Dreadnought} {ShipClass, ShipSpeed, Cloak}       JeffHicks_StarShipModule.ps1
    {cWindowsContainer}                {Ensure, ContainerType, AccessMode} BenGelens_CWindowsContainer.ps1
    
    .EXAMPLE

    "C:\Scripts\JeffHicks_StarShipModule.ps1" | Get-CUAst

    Classes                            Enums                               Source
    -------                            -----                               ------
    {mystarshIp, Cruiser, Dreadnought} {ShipClass, ShipSpeed, Cloak}       JeffHicks_StarShipModule.ps1

    .NOTES:
    
    .LINK
    https://github.com/Stephanevg/PSClassUtils/

    #>
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $false)
        ]
        [String[]]
        $InputObject,

    [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $true
    )]
    [Alias('FullName')]
    [String[]]$Path,
    [Parameter(Mandatory=$False)]
    [Switch]$Raw = $False
    )
    
    begin {

        function sortast {
            [CmdletBinding()]
            PAram(

                $RawAST,
                $Source,
                [switch]$Raw = $False
            )

            $Type = $RawAST.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
            [System.Management.Automation.Language.StatementAst[]] $Enums = @()
            $Enums = $type | ? {$_.IsEnum -eq $true}
            [System.Management.Automation.Language.StatementAst[]] $Classes = @()
            $Classes = $type | ? {$_.IsClass -eq $true}
            
            If ( $Raw ) {
                return [ASTDocument]::New($Classes,$Enums,$Source,$RawAST)
            } Else {
                return [ASTDocument]::New($Classes,$Enums,$Source)
            }

        }

    }
    
    process {


        if($Path){
            foreach($p in $Path){

                [System.IO.FileInfo]$File = Get-Item -Path $p
                Write-Verbose "AST: $($File.FullName)"
                $AST = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)
                If ( $Raw ) {
                    sortast -RawAST $AST -Source $File.FullName -Raw
                } Else {
                    sortast -RawAST $AST -Source $File.FullName
                }
            }
        }else{
        
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($InputObject, [ref]$null, [ref]$Null)
                If ( $Raw ) {
                    sortast -RawAST $AST -Source "Pipeline" -Raw
                } Else {
                    sortast -RawAST $AST -Source "Pipeline"
                }
        
        }

        


    }
    
    end {
    }
}

