#PS7
$SelectedFiles = $env:SELECTED_FILES -split "`r`n"
$Border = Read-Host -Prompt "Enter Border Image Patch (or leave blank for none):"
$MessageBox = Read-Host -Prompt "Enter Message Box Image Path (or leave blank for none):"
$Text = Read-Host -Prompt "Enter Text to Display in Message Box:"
$outputdir = Read-Host -Prompt "Enter Output Directory Path:"
$SelectedFiles | ForEach-Object {
    & magic.exe $_ $Border $MessageBox -layer flatten $outputdir
}
