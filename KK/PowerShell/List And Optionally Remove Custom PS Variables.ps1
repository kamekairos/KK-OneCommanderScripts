#PS7

$CustomAddedVars = Import-Clixml "$env:OC_SCRIPTS_DIR\..\KK\Export\CusPSVars.xml"

$SelectedVars = $CustomAddedVars | Out-GridView -Title "Select Vars To Remove!" -OutputMode Multiple

foreach ($VarKey in $SelectedVars.Key) {
        $CustomAddedVars.Remove("$VarKey")
}
$CustomAddedVars | Export-Clixml "$env:OC_SCRIPTS_DIR\..\KK\Export\CusPSVars.xml" -Force