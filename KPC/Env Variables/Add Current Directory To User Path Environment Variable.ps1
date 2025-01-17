#PS7
$ParseOCPath = Get-OCPath
Set-OCVars -CurrentDir $Env:Current_Dir
pwsh.exe -File "$ParseOCPath\Resources\KPC\Add-CurrentDirToEnvPath.ps1"