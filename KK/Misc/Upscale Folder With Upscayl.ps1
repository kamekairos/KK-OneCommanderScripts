#PS7
if ($env:CURRENT_DIR) {
    $SelectedFiles = $env:CURRENT_DIR -split "`r`n"
} else {
   $SelectedFiles = $env:SELECTED_FILES -split "`r`n"    
}
$Destination = "C:\Portable\upscayl\outputs\"
foreach ($file in $SelectedFiles) {
    & upscayl-bin.exe -i $file -o $Destination -m "C:\Portable\upscayl\resources\bin\models" -n "REALESRGAN_x4plus_Anime_6B" -z 8 -s 0 -g 0 -f png
}
$UpscayledFiles = Get-ChildItem -Path $Destination -File
