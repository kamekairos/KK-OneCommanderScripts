#PS7
$Files = $env:SELECTED_FILES -split "`r`n"
$Files | ForEach-Object {
    Unblock-File -Path $_
}