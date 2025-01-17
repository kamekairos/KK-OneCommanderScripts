#PS7
$SelectedFiles = $Env:Selected_Files -split "`r`n"
$SelectedFiles | ForEach-Object {cmd /K $_}
