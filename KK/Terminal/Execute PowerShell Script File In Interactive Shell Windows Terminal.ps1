#PS7
$SelectedFiles = $Env:Selected_Files -split "`r`n" 
$SelectedFiles | ForEach-Object {pwsh.exe -NoExit -File $_}
