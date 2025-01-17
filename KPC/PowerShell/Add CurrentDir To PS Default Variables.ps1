#PS7
$ParseOCPath = Get-OCPath
Set-OCVars -CurrentDir $Env:Current_Dir -SelMultiple $Env:Selected_Files -OpDir $Env:Current_Dir_Inactive -OpSelMultiple $Env:Selected_Files_Inactive
pwsh -File "$ParseOCPath\Resources\KPC\Add-OCVariableToPS.ps1"