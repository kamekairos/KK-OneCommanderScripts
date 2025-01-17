$OCVarHash = Get-OCVars
$SelectedFolders = $OCVarHash.SelectedFiles
$opDir = $OCVarHash.OpDir
$SelectedFolders | ForEach-Object {
    Move-Item -Path "$_\*" -Destination $opDir
}