#PS7
. "C:\Portables\OneCommander\Settings\OneCommanderProfile.ps1"
$ParseOCPath = Get-OCPath
Set-OCVars -SelMultiple $Env:Selected_Files -OpDir $Env:Current_Dir_Inactive
& pwsh -File (Join-Path $PSScriptRoot '..\..\..\KPC\Move-CurrentSelDirToOpDir.ps1')