using namespace System.Windows.Forms
using namespace System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$mainForm = New-Object Form
$mainForm.AutoSize = $true
$mainForm.StartPosition = "CenterScreen"
$mainForm.Text = "Get Package And Common Name Of Installed Apks"

$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Size(100, 25)
$label.Text = "Select which packages to list"

$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.AutoSize = $true
$checkbox1.Location = New-Object System.Drawing.Size(100, 50)
$checkbox1.Text = "Third Party Packages"

$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.AutoSize = $true
$checkbox2.Location = New-Object System.Drawing.Size(300, 50)
$checkbox2.Text = "System Packages"

$progressLabel1 = New-Object System.Windows.Forms.Label
$progressLabel1.AutoSize = $true
$progressLabel1.Location = New-Object System.Drawing.Size(100, 100)
$progressLabel1.Text = "Apk Pulling Progress"

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.AutoSize = $true
$progressBar.Location = New-Object System.Drawing.Size(100, 150)
$progressBar.Visible = $true
$progressBar.Minimum = 1
$progressBar.Value = 1

$progressLabel2 = New-Object System.Windows.Forms.Label
$progressLabel2.AutoSize = $true
$progressLabel2.Location = New-Object System.Drawing.Size(300, 100)
$progressLabel2.Text = "Apk Processing Progress"

$progressBar2 = New-Object System.Windows.Forms.ProgressBar
$progressBar2.AutoSize = $true
$progressBar2.Location = New-Object System.Drawing.Size(300, 150)
$progressBar2.Visible = $true
$progressBar2.Minimum = 1
$progressBar2.Value = 1

$button = New-Object System.Windows.Forms.Button
$button.AutoSize = $true
$button.Location = New-Object System.Drawing.Size(100, 200)
$button.Text = "OK"

$listBoxLabel = New-Object System.Windows.Forms.Label
$listBoxLabel.AutoSize = $true
$listBoxLabel.Location = New-Object System.Drawing.Size(100, 250)
$listBoxLabel.Text = "Select Apps From Results:"

$resultsListBox = New-Object System.Windows.Forms.ListBox
$resultsListBox.AutoSize = $true
$resultsListBox.Location = New-Object System.Drawing.Size(100, 300)
$resultsListBox.SelectionMode = "None"

$rsultsListCheckBoxLabel = New-Object System.Windows.Forms.Label
$rsultsListCheckBoxLabel.AutoSize = $true
$rsultsListCheckBoxLabel.Location = New-Object System.Drawing.Size(100, 800)
$rsultsListCheckBoxLabel.Text = "Select Action(s) To Take"

$resultsCheckBox1 = New-Object System.Windows.Forms.CheckBox
$resultsCheckBox1.AutoSize = $true
$resultsCheckBox1.Location = New-Object System.Drawing.Size(100, 800)
$resultsCheckBox1.Text = "Uninstall"

$resultsCheckBox2 = New-Object System.Windows.Forms.CheckBox
$resultsCheckBox2.AutoSize = $true
$resultsCheckBox2.Location = New-Object System.Drawing.Size(200, 800)
$resultsCheckBox2.Text = "Save Apks To Selected Location"

$resultsCheckBox3 = New-Object System.Windows.Forms.CheckBox
$resultsCheckBox3.AutoSize = $true
$resultsCheckBox3.Location = New-Object System.Drawing.Size(500, 800)
$resultsCheckBox3.Text = "Clear Cache"

$resultsCheckBox4 = New-Object System.Windows.Forms.CheckBox
$resultsCheckBox4.AutoSize = $true
$resultsCheckBox4.Location = New-Object System.Drawing.Size(700, 800)
$resultsCheckBox4.Text = "Clear Data"

$resultsButton = New-Object System.Windows.Forms.Button
$resultsButton.AutoSize = $true
$resultsButton.Location = New-Object System.Drawing.Size(100, 850)
$resultsButton.Text = "Clear Data"

$buttonSB = {
    $Script:Args1 = @()
    if ($checkbox1.Checked -and $checkbox2.Checked) {
        $Script:Args1 = "-d", "shell", "pm", "list", "packages", "-a", "-f"
    }
    if ($checkbox1.Checked -and !($checkbox2.Checked)) {
        $Script:Args1 = "-d", "shell", "pm", "list", "packages", "-3", "-f"
    }
    if (!($checkbox1.Checked) -and $checkbox2.Checked) {
        $Script:Args1 = "-d", "shell", "pm", "list", "packages", "-s", "-f"
    }
    $NewLineSplitPackages = & "$PSScriptRoot\Tools\adb.exe" @Args1
    $ParsedADBPaths = @()
    $ParsedADBPackageNames = @()
    foreach ($line in $NewLineSplitPackages) {
        $ParsedPath1 = ($line -replace '^package:' -replace '(?<=base\.apk).*')
        $PackageName = ($line -split "=")[-1].ToString()
        $ParsedADBPaths += $ParsedPath1
        $ParsedADBPackageNames += $PackageName
    }
    $progressBar.Maximum = $ParsedADBPaths.Count
    if (Test-Path "$PSScriptRoot\Export\ApkFiles\") {
        Remove-Item -Path "$PSScriptRoot\Export\ApkFiles\" -Recurse -Force
    }
    New-Item -Path "$PSScriptRoot\Export\ApkFiles\" -ItemType Directory -Force
    for ($i = 0; $i -lt $ParsedADBPaths.Count; $i++) {
        $Args2 = "pull", "$($ParsedADBPaths[$i])", "$PSScriptRoot\Export\ApkFiles\$($ParsedADBPackageNames[$i]).apk"
        & "$PSScriptRoot\Tools\adb.exe" @Args2
        $progressBar.Increment(1)
    }
    $GetApks = Get-ChildItem -Path "$PSScriptRoot\Export\ApkFiles\" -File -Force
    $CommonNames = @{}
    $progressBar2.Maximum = $GetApks.Count
    foreach ($apk in $GetApks) {
        $Args3 = "dump", "badging", "$($apk.FullName)"
        $RawAAPT2Dump = & "$PSScriptRoot\Tools\aapt2.exe" @Args3
        $ParsedDump = $RawAAPT2Dump | Select-String "(?<=application-label:')[^']+" | ForEach-Object { $_.Matches.Value }
        $CommonNames.Add($apk.BaseName, $ParsedDump)
        $progressBar2.Increment(1)
    }
    $SortedApksByCommonName = $CommonNames.GetEnumerator() | Sort-Object -Property Value
    $Script:Results = $SortedApksByCommonName | Out-GridView -Title "Apks & Names" -OutputMode Multiple
    

    foreach ($result in $Script:Results) {
        $resultsListBox.Items.Add($result.Value)
    }
}
$resultButtonSB = {
    $SelectFolder = New-Object System.Windows.Forms.FolderBrowserDialog
    foreach ($result in $Script:Results) {
        if ($resultsCheckBox1.Checked) {
            $uninstallArgs = "uninstall", "$($result.Key)"
            & "$PSScriptRoot\Tools\adb.exe" @uninstallArgs
        }
        if ($resultsCheckBox2.Checked) {
            if ($SelectFolder.ShowDialog() -eq "OK") {
                $selectedFolder = $SelectFolder.SelectedPath   
                Copy-Item -Path (Get-ChildItem -Path "$PSScriptRoot\Export\ApkFiles\$($result.Key).apk").FullName -Destination $selectedFolder
            }
        }
        if ($resultsCheckBox3.Checked) {
            $cacheArgs = '-d', 'shell', 'pm', 'clear', '--cache-only', "$($result.Key)"
            & "$PSScriptRoot\Tools\adb.exe" @cacheArgs
        }
        if ($resultsCheckBox4) {
            $cacheArgs = '-d', 'shell', 'pm', 'clear', "$($result.Key)"
            & "$PSScriptRoot\Tools\adb.exe" @cacheArgs
        }
    }
    $mainForm.Close()
}

$button.Add_Click($buttonSB)
$resultsButton.Add_Click($resultButtonSB)

$mainForm.Controls.Add($label)
$mainForm.Controls.Add($checkbox1)
$mainForm.Controls.Add($checkbox2)
$mainForm.Controls.Add($progressLabel1)
$mainForm.Controls.Add($progressLabel2)
$mainForm.Controls.Add($progressBar)
$mainForm.Controls.Add($progressBar2)
$mainForm.Controls.Add($button)
$mainForm.Controls.Add($listBoxLabel)
$mainForm.Controls.Add($resultsListBox)
$mainForm.Controls.Add($resultsCheckBox1)
$mainForm.Controls.Add($resultsCheckBox2)
$mainForm.Controls.Add($resultsCheckBox3)
$mainForm.Controls.Add($resultsCheckBox4)
$mainForm.Controls.Add($resultsButton)


$mainForm.ShowDialog()



