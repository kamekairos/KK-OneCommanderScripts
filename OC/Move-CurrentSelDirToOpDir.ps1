$OCVarHash = Get-OCVars
$SelectedFolders = $OCVarHash.$SelMultiple
$opDir = $OCVarHash.OpDir
$SelectedFolders | ForEach-Object {
    Move-Item -Path "$_\*" -Destination $opDir -Force 
}