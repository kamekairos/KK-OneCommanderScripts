#PS7
$CurDir = $env:CURRENT_DIR
$VarName = Read-Host -Prompt "Please Enter The Name of the Variable To represent the path: $CurDir"
$CustomAddedVars = Import-Clixml "$env:OC_SCRIPTS_DIR\..\KPC\Export\CusPSVars.xml"
$CustomAddedVars.Add($VarName,$CurDir)

$CustomAddedVars | Export-Clixml -Path "$env:OC_SCRIPTS_DIR\..\KPC\Export\CusPSVars.xml" -Force