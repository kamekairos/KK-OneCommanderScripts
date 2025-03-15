#PS7
using namespace System.Windows.Forms
using namespace System.Drawing

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$OCVars = Get-OCVars
$CurDir = $OCVars.CurrentDir
$OpDir = $OCVars.OpDir
$SelectedItems = $OCVars.SelectedFiles -split "\n"

$SelectedADBSerial = Get-ADBDevice

adb kill-server

$Global:CurFolPath = "/sdcard/"
$adbInitFolders = & "$PSScriptRoot\Tools\adb.exe" "-s" $SelectedADBSerial "shell" "ls" "$($Global:CurFolPath)"

$form = [Form]::new()
$form.Size = [Size]::new(1000,900)
$form.BackColor = [Color]::White
$form.StartPosition = [FormStartPosition]::CenterScreen
$form.Font = $DefaultFont.Font

$page1MenuButton1Image = [Image]::FromFile("$PSScriptRoot\Assests\uparrow.png")

$page1MenuButton1 = [Button]::new()
$page1MenuButton1.Size = [Size]::new(50,50)
$page1MenuButton1.Image = $page1MenuButton1Image

$page1Panel = [Panel]::new()
$page1Panel.Dock = [DockStyle]::Fill

$page2Panel = [Panel]::new()
$page2Panel.Dock = [DockStyle]::Fill

$page3Panel = [Panel]::new()
$page3Panel.Dock = [DockStyle]::Fill

$page1MenuPanel = [Panel]::new()
$page1MenuPanel.Dock = "Top"
$page1MenuPanel.Height = 50
$page1MenuPanel.BackColor = [Color]::Black
$page1MenuPanel.Padding = [Padding]::new(0)
$page1MenuPanel.Margin = [Padding]::new(0)
$page1MenuPanel.Controls.Add($page1MenuButton1)


$lvImageList = [ImageList]::new()
$lvImageList.Images.Add([Image]::FromFile("$PSScriptRoot\Assests\folder.png"))
$lvImageList.Images.Add([Image]::FromFile("$PSScriptRoot\Assests\file.png"))
$lvImageList.ImageSize = [Size]::new(50,50)

$listView = [ListView]::new()
$listView.BorderStyle = [BorderStyle]::None
$listView.Dock = [DockStyle]::Fill
$listView.View = [View]::LargeIcon
$listView.BackColor = [Color]::Black
$listView.ForeColor = [Color]::White
$listView.LargeImageList = $lvImageList
foreach ($Item in $adbInitFolders) {
    $listView.Items.Add($Item,0)
}

$listView.Add_DoubleClick({
    Write-Host "In The DoubleClick"
    Write-Host "$($listView.SelectedItems[0].Text)"
    $Folder = $listView.SelectedItems[0].Text
    $Global:CurFolPath = $Global:CurFolPath + $Folder + "/"
    $Items = adb -s $SelectedADBSerial shell ls $Global:CurFolPath
    $listView.Clear()
    foreach ($Item in $Items) {
        if (!($Item -like "*.*")) {
        $ListItem = [ListViewItem]::new($Item, 0)
        $listView.Items.Add($ListItem)
        }
    
    else {
        $ListItem = [ListViewItem]::new($Item, 1)
        $listView.Items.Add($ListItem)
    }
}
    $listView.Refresh()
}
)

$listViewWrapperPanel = [Panel]::new()
$listViewWrapperPanel.Location = [Point]::new(50,50)
$listViewWrapperPanel.Dock = "Fill"
$listViewWrapperPanel.Padding = [Padding]::new(0)
$listViewWrapperPanel.Controls.Add($listView)

$mainMenuButton1 = [Button]::new()
$mainMenuButton1.MinimumSize = [Size]::new(200,50)
$mainMenuButton1.Text = "Browse Phone"

$mainMenuButton2 = [Button]::new()
$mainMenuButton2.MinimumSize = [Size]::new(200,50)
$mainMenuButton2.Location = [Point]::new(0,50)
$mainMenuButton2.Text = "Install Apk(s)"

$mainMenuButton3 = [Button]::new()
$mainMenuButton3.MinimumSize = [Size]::new(200,50)
$mainMenuButton3.Location = [Point]::new(0,100)
$mainMenuButton3.Text = "Get Apk Common Names"

$mainMenu = [Panel]::new()
$mainMenu.Margin = [Padding]::new(0,0,5,0)
$mainMenu.Dock = "Left"
$mainMenu.BackColor = [Color]::Black
$mainMenu.ForeColor = [Color]::White
$mainMenu.Controls.Add($mainMenuButton1)
$mainMenu.Controls.Add($mainMenuButton2)
$mainMenu.Controls.Add($mainMenuButton3)

$page1BottomButton1 = [Button]::new()
$page1BottomButton1.Dock = "Top"
$page1BottomButton1.Text = "Select Folder To Transfer Files To"

$page1BottomButton2 = [Button]::new()
$page1BottomButton2.Dock = "top"
$page1BottomButton2.Text = "Transfer To Current Directory"

$page1BottomButton3 = [Button]::new()
$page1BottomButton3.Dock = "Top"
$page1BottomButton3.Text = "Transfer To Opposite Directory"

$page1BottomButton4 = [Button]::new()
$page1BottomButton4.Dock = "Top"
$page1BottomButton4.Text = "Transfer Selected Files To Open Phone Directory"

$page1BottomButton1.Add_Click(
    {
        $fbd = [FolderBrowserDialog]::new()
        $fbd.ShowDialog()
        Start-Sleep -Milliseconds 50
        $listView.SelectedItems.Text | ForEach-Object -Process {
            if ($_ -like "*.*") {
              & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial pull ($Global:CurFolPath + $_) $fbd.SelectedPath
            }
            else {
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial pull ($Global:CurFolPath + $_ + "/") $fbd.SelectedPath
            }
        }
        Start-Sleep -Milliseconds 50
            [MessageBox]::Show("All Files Have Transfered Successfully","Sucess!","Ok")
    }
)

$page1BottomButton2.Add_Click(
    {
        $listView.SelectedItems.Text | ForEach-Object -Process {
            if ($_ -like "*.*") {
              & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial pull ($Global:CurFolPath + $_) $CurDir
            }
            else {
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial pull ($Global:CurFolPath + $_ + "/") $CurDir
            }
        }
        Start-Sleep -Milliseconds 50
            [MessageBox]::Show("All Files Have Transfered Successfully","Sucess!","Ok")
    }
)

$page1BottomButton3.Add_Click(
    {
        $listView.SelectedItems.Text | ForEach-Object -Process {
            if ($_ -like "*.*") {
              & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial  pull ($Global:CurFolPath + $_) $OpDir
            }
            else {
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial  pull ($Global:CurFolPath + $_ + "/") $OpDir
            }
        }
        Start-Sleep -Milliseconds 50
            [MessageBox]::Show("All Files Have Transfered Successfully","Sucess!","Ok")
    }
)

$page1BottomButton4.Add_Click(
    {
        Write-Host "In Button 4 Click"
        $SelectedItems
        $SelectedItems | ForEach-Object {
            & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial push $_ ($Global:CurFolPath + "/")
            }
        Start-Sleep -Milliseconds 50
            [MessageBox]::Show("All Files Have Transfered Successfully","Sucess!","Ok")
    }
)


$page1BottomPanel = [Panel]::new()
$page1BottomPanel.Dock = "Bottom"
$page1BottomPanel.AutoSize = $true
$page1BottomPanel.Controls.Add($page1BottomButton1)
$page1BottomPanel.Controls.Add($page1BottomButton2)
$page1BottomPanel.Controls.Add($page1BottomButton3)
$page1BottomPanel.Controls.Add($page1BottomButton4)


$page1Panel.Controls.Add($listViewWrapperPanel)
$page1Panel.Controls.Add($page1MenuPanel)
$page1Panel.Controls.Add($page1BottomPanel)


$page2Button1 = [Button]::new()
$page2Button1.AutoSize = $true
$page2Button1.Dock = "Top"
$page2Button1.Text = "Select Apke(s) To Install"

$page2BottomPanelButton = [Button]::new()
$page2BottomPanelButton.AutoSize = $true
$page2BottomPanelButton.Dock = "Fill"
$page2BottomPanelButton.Text = "Install Apk(s) To Connected Phone"

$page2BottomPanel = [Panel]::new()
$page2BottomPanel.Dock = "Bottom"
$page2BottomPanel.Height = 100
$page2BottomPanel.Controls.Add($page2BottomPanelButton)


$page2ListBoxSelectedFiles = [listbox]::new()
$page2ListBoxSelectedFiles.Dock = "Fill"
$page2ListBoxSelectedFiles.Top = 50
$page2ListBoxSelectedFiles.HorizontalScrollbar = $true
$page2ListBoxSelectedFiles.Height = 700

$page2FileSelectDialog = [OpenFileDialog]::new()
$page2FileSelectDialog.Multiselect = $true

$page2Panel.Controls.Add($page2ListBoxSelectedFiles)
$page2Panel.Controls.Add($page2Button1)
$page2Panel.Controls.Add($page2BottomPanel)



$page1MenuButton1.Add_Click(
    {
            $Global:PrePath = $Global:CurFolPath
            if ($Global:PrePath -ne "/sdcard/") {
            $TempList = $Global:PrePath.Split('/', [StringSplitOptions]::RemoveEmptyEntries)
            $RepText = $TempList[-1]
            $Global:PrePath = ($Global:PrePath).Replace("$RepText/","")
            $Items = & "$PSScriptRoot\Tools\adb.exe" "-s" $SelectedADBSerial "shell" "ls" "$($Global:PrePath)"
            $Global:CurFolPath = $Global:PrePath
            $ListView.Clear()
            foreach ($Item in $Items) {
                if (!($Item -like "*.*")) {
                    $ListItem = [ListViewItem]::new($Item, 0)
                    $listView.Items.Add($ListItem)
                    }
                
                else {
                    $ListItem = [ListViewItem]::new($Item, 1)
                    $listView.Items.Add($ListItem)
                }
            }
            $ListView.Refresh()
        }
            else {
                [MessageBox]::Show("You are already at top level!","No Further To Go!",[MessageBoxButtons]::OK)
            }
    }
)

$page2Button1.Add_Click(
    {
        $results = $page2FileSelectDialog.ShowDialog()
        if ($results -eq "OK") {
            Write-Host "We're In!"
        $page2ListBoxSelectedFiles.Items.Clear()
        Start-Sleep -Milliseconds 50
        foreach ($File in $page2FileSelectDialog.FileNames) {
            $page2ListBoxSelectedFiles.Items.Add(($File))
        }
    }
    else {
        Write-Host "Dialog Canceled"
    }

    }
)

$page2BottomPanelButton.Add_Click(
    {
        foreach ($FileName in $page2FileSelectDialog.FileNames) {
            & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial install $FileName
        }
        [MessageBox]::Show("Apk(s) Sucessfully Installed","Sucess!","Ok")
        $page2ListBoxSelectedFiles.Items.Clear()
    }
)

$mainMenuButton1.Add_Click(
    {
        $form.Controls.Clear()
        Start-Sleep -Milliseconds 50
        $form.Controls.Add($page1Panel)
        $form.Controls.Add($mainMenu)
    }
)

$mainMenuButton2.Add_Click(
    {
        $form.Controls.Clear()
        Start-Sleep -Milliseconds 50
        $form.Controls.Add($page2Panel)
        $form.Controls.Add($mainMenu)
    }
)

$mainMenuButton3.Add_Click(
    {
        $form.Controls.Clear()
        Start-Sleep -Milliseconds 50
        $form.Controls.Add($page3Panel)
        $form.Controls.Add($mainMenu)
    }
)

$label = [Label]::new()
$label.AutoSize = $true
$label.Location =[Point]::new(100,25)
$label.Text = "Select which packages to list"

$checkbox1 = [CheckBox]::new()
$checkbox1.AutoSize = $true
$checkbox1.Location = [Point]::new(100, 50)
$checkbox1.Text = "Third Party Packages"

$checkbox2 = [CheckBox]::new()
$checkbox2.AutoSize = $true
$checkbox2.Location = [Point]::new(300, 50)
$checkbox2.Text = "System Packages"

$progressLabel1 = [Label]::new()
$progressLabel1.AutoSize = $true
$progressLabel1.Location = [Point]::new(100, 100)
$progressLabel1.Text = "Apk Pulling Progress"

$progressBar = [ProgressBar]::new()
$progressBar.AutoSize = $true
$progressBar.Location = [Point]::new(100, 150)
$progressBar.Visible = $true
$progressBar.Minimum = 1
$progressBar.Value = 1

$progressLabel2 = [Label]::new()
$progressLabel2.AutoSize = $true
$progressLabel2.Location = [Point]::new(300, 100)
$progressLabel2.Text = "Apk Processing Progress"

$progressBar2 = [ProgressBar]::new()
$progressBar2.AutoSize = $true
$progressBar2.Location = [Point]::new(300, 150)
$progressBar2.Visible = $true
$progressBar2.Minimum = 1
$progressBar2.Value = 1

$button = [Button]::new()
$button.AutoSize = $true
$button.Location = [Point]::new(100, 200)
$button.Text = "OK"

$listBoxLabel = [Label]::new()
$listBoxLabel.AutoSize = $true
$listBoxLabel.Location = [Point]::new(100, 250)
$listBoxLabel.Text = "Select Apps From Results:"

$resultsListBox = [ListBox]::new()
$resultsListBox.AutoSize = $true
$resultsListBox.Location = [Point]::new(100, 300)
$resultsListBox.SelectionMode = "None"

$rsultsListCheckBoxLabel = [Label]::new()
$rsultsListCheckBoxLabel.AutoSize = $true
$rsultsListCheckBoxLabel.Location = [Point]::new(100, 800)
$rsultsListCheckBoxLabel.Text = "Select Action(s) To Take"

$resultsCheckBox1 = [CheckBox]::new()
$resultsCheckBox1.AutoSize = $true
$resultsCheckBox1.Location = [Point]::new(100, 800)
$resultsCheckBox1.Text = "Uninstall"

$resultsCheckBox2 = [CheckBox]::new()
$resultsCheckBox2.AutoSize = $true
$resultsCheckBox2.Location = [Point]::new(200, 800)
$resultsCheckBox2.Text = "Save Apks To Selected Location"

$resultsCheckBox3 = [CheckBox]::new()
$resultsCheckBox3.AutoSize = $true
$resultsCheckBox3.Location = [Point]::new(500, 800)
$resultsCheckBox3.Text = "Clear Cache"

$resultsCheckBox4 = [CheckBox]::new()
$resultsCheckBox4.AutoSize = $true
$resultsCheckBox4.Location = [Point]::new(700, 800)
$resultsCheckBox4.Text = "Clear Data"

$resultsButton = [Button]::new()
$resultsButton.AutoSize = $true
$resultsButton.Location = [Point]::new(100, 850)
$resultsButton.Text = "Clear Data"




$button.Add_Click(
    {
        $Global:Args1 = @()
        if ($checkbox1.Checked -and $checkbox2.Checked) {
            $Global:Args1 = "shell", "pm", "list", "packages", "-a", "-f"
        }
        if ($checkbox1.Checked -and !($checkbox2.Checked)) {
            $Global:Args1 = "shell", "pm", "list", "packages", "-3", "-f"
        }
        if (!($checkbox1.Checked) -and $checkbox2.Checked) {
            $Global:Args1 = "shell", "pm", "list", "packages", "-s", "-f"
        }
        $NewLineSplitPackages = & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial @Args1
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
            & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial @Args2
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
        Write-Host "Here 1"
        $SortedApksByCommonName = $CommonNames.GetEnumerator() | Sort-Object -Property Value
        Write-Host "Here 2"
        $Global:Results = $SortedApksByCommonName | Out-GridView -Title "Apks & Names" -OutputMode Multiple
        Write-Host "Here 3"
        
    
        foreach ($result in $Global:Results) {
            Write-Host "Here 4"
            $resultsListBox.Items.Add($result.Value)
        }
    }
)
$resultsButton.Add_Click(
    {
        $SelectFolder = [FolderBrowserDialog]::new()
        foreach ($result in $Global:Results) {
            if ($resultsCheckBox1.Checked) {
                Write-Host "$($result.Key)"
                $uninstallArgs = "uninstall", "$($result.Key)"
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial @uninstallArgs
            }
            if ($resultsCheckBox2.Checked) {
                if ($SelectFolder.ShowDialog() -eq "OK") {
                    $selectedFolder = $SelectFolder.SelectedPath   
                    Copy-Item -Path (Get-ChildItem -Path "$PSScriptRoot\Export\ApkFiles\$($result.Key).apk").FullName -Destination $selectedFolder
                }
            }
            if ($resultsCheckBox3.Checked) {
                $cacheArgs = '-d', 'shell', 'pm', 'clear', '--cache-only', "$($result.Key)"
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial @cacheArgs
            }
            if ($resultsCheckBox4) {
                $cacheArgs = '-d', 'shell', 'pm', 'clear', "$($result.Key)"
                & "$PSScriptRoot\Tools\adb.exe" -s $SelectedADBSerial @cacheArgs
            }
        }
    }
)

$page3Panel.Controls.Add($label)
$page3Panel.Controls.Add($checkbox1)
$page3Panel.Controls.Add($checkbox2)
$page3Panel.Controls.Add($progressLabel1)
$page3Panel.Controls.Add($progressLabel2)
$page3Panel.Controls.Add($progressBar)
$page3Panel.Controls.Add($progressBar2)
$page3Panel.Controls.Add($button)
$page3Panel.Controls.Add($listBoxLabel)
$page3Panel.Controls.Add($resultsListBox)
$page3Panel.Controls.Add($resultsCheckBox1)
$page3Panel.Controls.Add($resultsCheckBox2)
$page3Panel.Controls.Add($resultsCheckBox3)
$page3Panel.Controls.Add($resultsCheckBox4)
$page3Panel.Controls.Add($resultsButton)

$form.Controls.Add($page1Panel)
$form.Controls.Add($mainMenu)

$form.ShowDialog()
