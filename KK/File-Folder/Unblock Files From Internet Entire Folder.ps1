 $folder = $Env:Current_DIR
 $Files = Get-ChildItem -Path $folder -Recurse -File | Select-Object -ExpandProperty FullName -split "`r`n"
$Files | ForEach-Object {
    Unblock-File -LiteralPath $_
}