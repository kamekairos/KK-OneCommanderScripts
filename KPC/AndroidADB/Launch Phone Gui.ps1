#PS7
. $PROFILE
$ParseOCPath = Get-OCPath
Set-OCVars -CurrentDir $Env:Current_Dir -SelMultiple $Env:Selected_Files -OpDir $Env:Current_Dir_Inactive
. "$ParseOCPath\Resources\KPC\Invoke-PhoneGui.ps1"