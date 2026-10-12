#PWSH
$SelectedFiles = $Env:Selected_Files -split "`r`n" 
$SelectedFiles | ForEach-Object {pwsh.exe -NoExit -File $_}.WaitForExit()
