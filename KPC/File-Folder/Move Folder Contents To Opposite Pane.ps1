#PS7
$ParseOCPath = Get-OCPath
Set-OCVars -SelMultiple $Env:Selected_Items -OpDir $Env:Current_Dir_Inactive
& pwsh -File (Join-Path $ParseOCPath 'Resources\KPC\Move-CurrentSelDirToOpDir.ps1')