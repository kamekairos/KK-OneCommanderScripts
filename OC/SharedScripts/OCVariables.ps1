function Set-OCVars {
    param(
    [Parameter(Mandatory = $false,
        HelpMessage = 'OC Current Directory Variable/Path ($CurrentDir)')]
    [string]
    $CurrentDir,
    [Parameter(Mandatory = $false,
        HelpMessage = 'OC Current Selected Files ($SelMultiple)')]
    [string]
    $SelMultiple,
    [Parameter(Mandatory = $false,
        HelpMessage = 'OC Opposite Directory Variable/Path ($OpDir)')]
    [string]
    $OpDir,
    [Parameter(Mandatory = $false,
        HelpMessage = 'OC Opposite Selected Files ($OpSelMultiple)')]
    [string]
    $OpSelMultiple
)
$SelMultList = ($SelMultiple -split "\r?\n")
$OpSelMultList = ($OpSelMultiple -split "\r?\n")

$OCVarHash = @{
    CurrentDir     = $CurrentDir
    SelectedFiles = $SelMultList
    OpDir    = $OpDir
    OpSelectedFiles = $OpSelMultList
}
$OCVarHash | Export-Clixml -Path "$PSScriptRoot\..\Export\Vars.xml" -Force

}

function Get-OCVars {
    $GetOCVars = Import-Clixml -Path "$PSScriptRoot\..\Export\Vars.xml"
    return $GetOCVars
}