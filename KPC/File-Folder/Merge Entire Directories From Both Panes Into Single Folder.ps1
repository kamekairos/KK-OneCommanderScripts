#PS7
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$CurDir = $env:CURRENT_DIR
$OpDir = $Env:Current_Dir_Inactive

$FolderPathDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderPathDialog.Description = "Choose A Destination Path To Merge Both Panes Into"
$FolderPathDialog.RootFolder = "MyComputer"
$FolderPathDialog.SelectedPath = "$env:SystemDrive"

if ($FolderPathDialog.ShowDialog() -eq "OK") {
    Copy-Item -Path "$CurDir\*" -Destination $FolderPathDialog.SelectedPath -Recurse -Force
    Copy-Item -Path "$OpDir\*" -Destination $FolderPathDialog.SelectedPath -Recurse -Force
}
elseif ($FolderPathDialog.ShowDialog() -eq "CANCEL") {
    $ButtonType = [System.Windows.Forms.MessageBoxButtons]::Ok

$MessageIcon = [System.Windows.Forms.MessageBoxIcon]::Information

$MessageBody = "You have canceled the Folder Picking Dialog. Ending Script."

$MessageTitle = "Dialog Closed"

[System.Windows.Forms.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}
else {
    $ButtonType2 = [System.Windows.Forms.MessageBoxButtons]::Ok

$MessageIcon2 = [System.Windows.Forms.MessageBoxIcon]::Warning

$MessageBody2 = "An Unknown Error Occured. Ending Script."

$MessageTitle2 = "Unknown Error"

[System.Windows.Forms.MessageBox]::Show($MessageBody2,$MessageTitle2,$ButtonType2,$MessageIcon2)
}

