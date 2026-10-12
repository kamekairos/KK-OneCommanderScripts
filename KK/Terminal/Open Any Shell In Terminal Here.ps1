#PWSH
$wtSettingFiles = (Get-ChildItem -Recurse -Filter settings.json "$env:LOCALAPPDATA\Packages\*WindowsTerminal*", "$env:LOCALAPPDATA\Microsoft\Windows Terminal*") | Select-Object FullName

if ($wtSettingFiles.Count -eq 0) {
    Write-Host "No Windows Terminal settings.json file found."
    exit
}

if ($wtSettingFiles.Count -gt 1) {
    Write-Host "Multiple Windows Terminal settings.json files found. Please select one:"

# Display numbered list
for ($i = 0; $i -lt $wtSettingFiles.Count; $i++) {
    Write-Host "$($i): $($wtSettingFiles[$i].FullName)"
}

# Build ChoiceDescription array
$choices = @()
foreach ($file in $wtSettingFiles) {
    $choices += [System.Management.Automation.Host.ChoiceDescription]::new($file.FullName)
}

# Prompt user
$selectedIndex = Read-Host "Pick A Number From Above"

# Retrieve selected file
$wtSettingFile = $wtSettingFiles[$selectedIndex].FullName

}
else {
    $wtSettingFile = $wtSettingFiles[0].FullName
}

$wtContentJson = Get-Content -Raw -Path $wtSettingFile

$CurDir = $env:CURRENT_DIR
$wtContentObj = $wtContentJson | ConvertFrom-Json
$promptGuids = $wtContentObj.profiles.list.guid
$promptNames = $wtContentObj.profiles.list.name

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Size = New-Object System.Drawing.Size(500,500)
$mainForm.StartPosition = "CenterScreen"

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(425,350)
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
    wt -p $CurGuid -d $CurDir
    $mainForm.Close() | Out-Null
}

$okButton.Add_Click($Script:LaunchTerminalCmd)


$mainForm.ShowDialog() | Out-Null