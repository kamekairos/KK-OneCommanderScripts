#PWSH
$CustomAddedVars = Import-Clixml "$Env:OC_SCRIPTS_DIR\..\KK\Export\CusPSVars.xml"

$RemoveVariables = $host.UI.PromptForChoice('Remove Custom PS Variables?', 'Do you want to remove any of the custom PS variables?', [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No"), 1)

if ($RemoveVariables -eq 0) {
    $SelectedVars = $CustomAddedVars | Out-GridView -Title "Select Vars To Remove!" -OutputMode Multiple


foreach ($VarKey in $SelectedVars.Key) {
        $CustomAddedVars.Remove("$VarKey")
}

$CustomAddedVars | Export-Clixml "$Env:OC_SCRIPTS_DIR\..\KK\Export\CusPSVars.xml" -Force
}
else {
    $customaddedvars | Out-GridView -Title "Custom PS Variables" -Wait
}