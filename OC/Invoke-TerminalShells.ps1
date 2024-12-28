try {
    $wtContentJson = Get-Content -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -ErrorAction Stop
}
catch {
    $wtContentJson = Get-Content -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
}
$OCVars = Get-OCVars
$wtContentObj = $wtContentJson | ConvertFrom-Json
$promptGuids = $wtContentObj.profiles.list.guid
$promptNames = $wtContentObj.profiles.list.name

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Size = New-Object System.Drawing.Size(500,850)
$mainForm.StartPosition = "CenterScreen"

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(425,650)
$listBox.Location = New-Object System.Drawing.Size(25,25)
foreach ($promptName in $promptNames) {
$listBox.Items.Add($promptName) | Out-Null
}

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "Launch Prompt"
$okButton.Size = New-Object System.Drawing.Size(100,50)
$okButton.Dock = "Bottom"

$mainForm.Controls.Add($listBox)
$mainForm.Controls.Add($okButton)

$Script:LaunchTerminalCmd = {
    $CurGuid = $promptGuids[$listBox.SelectedIndex]
    wt -p $CurGuid -d $OCVars.CurrentDir
    $mainForm.Close() | Out-Null
}

$okButton.Add_Click($Script:LaunchTerminalCmd)


$mainForm.ShowDialog() | Out-Null

