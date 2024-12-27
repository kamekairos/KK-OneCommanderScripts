#PS7
$ParseOCPath = Get-OCPath

Set-OCVars -CurrentDir $env:Current_Dir -SelMultiple $env:Selected_Files -OpDir $Env:Current_Dir_Inactive -OpSelMultiple $Env:Selected_Files_Inactive

pwsh.exe -File "$ParseOCPath\Resources\KPC\Invoke-TerminalShells.ps1"