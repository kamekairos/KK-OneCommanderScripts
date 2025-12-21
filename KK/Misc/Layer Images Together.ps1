#PS7
$SelectedFiles = $env:SELECTED_FILES -split "`r`n"
# $Border = Read-Host -Prompt "Enter Border Image Patch (or leave blank for none):"
$Border = "C:\MINTEI\media\trading cards\CardsTemplateBatchBorderGotchic.png"
# $MessageBox = Read-Host -Prompt "Enter Message Box Image Path (or leave blank for none):"
$MessageBox = "C:\MINTEI\media\trading cards\CardsTemplateBatchMessageBox.png"
# $Text = Read-Host -Prompt "Enter Text to Display in Message Box:"
$Text2 = $Text -split ","
# $outputdir = Read-Host -Prompt "Enter Output Directory Path:"
$outputdir = "C:\MINTEI\media\trading cards\outputs\"
Set-Location "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\"
for ($i=0; $i -lt $SelectedFiles.Count; $i++) {
    $inputfile = $SelectedFiles[$i]
    $outputfile = Join-Path -Path $outputdir -ChildPath (Split-Path -Path $inputfile -Leaf)
    $output = "$outputfile"
. ".\magick" $inputfile $Border -layers flatten -font "Arial-Bold" -pointsize 55 -fill black -gravity south -annotate +0+250 "$($Text2[$i])" "$output"
}
