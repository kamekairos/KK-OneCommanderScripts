#PS7
Add-Type -Path "C:\Users\nroot\Downloads\microsoft.windows.sdk.net.ref.10.0.26100.57\lib\net8.0\Microsoft.Windows.SDK.NET.dll"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$SelectedFile = ($env:Selected_Files)[0]

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($WinRtTask, $ResultType) {
 $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
 $netTask = $asTask.Invoke($null, @($WinRtTask))
 $netTask.Wait(-1) | Out-Null
 $netTask.Result
}
$op = [Windows.ApplicationModel.DataTransfer.Clipboard]::GetHistoryItemsAsync()
$result = Await ($op) ([Windows.ApplicationModel.DataTransfer.ClipboardHistoryItemsResult])

$op2 = $result.Items.Content.GetTextAsync()
$listy = @()
foreach($o in $op2) {
    
$listycandidate = Await ($o) ([string])
if ($null -ne $listycandidate) {
    $listy += $listycandidate
}
}


$mainform = New-Object System.Windows.Forms.Form
$mainform.AutoScaleMode = "Dpi"
$mainform.AutoSize = $true
$mainform.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowOnly
$mainform.Text = "Rename With Clipboard History"
$mainform.StartPosition = "CenterScreen"
$mainform.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$mainform.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$mainform.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$mainform.ControlBox = $true
$mainform.TopMost = $true
$mainform.Font = [System.Drawing.Font]::new("Consolas",14)
$padding1 = $mainform.Padding
$padding1.All = 15
$mainform.Padding = $padding1

$flowlayoutpanel1 = New-Object System.Windows.Forms.FlowLayoutPanel
$flowlayoutpanel1.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowlayoutpanel1.WrapContents = $false
$flowlayoutpanel1.Dock = "Fill"
$flowlayoutpanel1.AutoSize = $true


$label = New-Object System.Windows.Forms.Label
$label.Text = "Please Select A Clipboard Item And Hit Rename"
$label.Dock = "Top"
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$label.AutoSize = $true
$label.ForeColor = [System.Drawing.Color]::FromArgb(0, 178, 255)

$listbox = New-Object System.Windows.Forms.ListBox
foreach($item in $listy) {
$listbox.Items.Add($item)
}
$listbox.Height = (($listbox.ItemHeight + 5) * $listbox.Items.Count) + 100
$listbox.Width = $button1.Width
#$listbox.HorizontalExtent = $button1.Width
$listbox.HorizontalScrollbar = $true
#$listbox.ScrollAlwaysVisible = $true
$listbox.BackColor = [System.Drawing.Color]::FromArgb(57, 57, 57)
$listbox.ForeColor = "White"
$listbox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$padding2 = $listbox.Padding
$padding2.All = 15
$listbox.Padding = $padding2

$textbox = New-Object System.Windows.Forms.TextBox

$button1 = New-Object System.Windows.Forms.Button
$button1.Text = "Rename"
$button1.AutoSize = $true
$button1.Dock = "Bottom"

$flowlayoutpanel1.Controls.Add($label)
$flowlayoutpanel1.Controls.Add($listbox)
$flowlayoutpanel1.Controls.Add($button1)



$mainform.Controls.Add($flowlayoutpanel1)
<#>
$mainform.Add_Resize({
    $listbox.Size = [System.Drawing.Size]::new(($mainform.ClientSize.Width - 2 * $mainform.Padding.Left),($mainform.ClientSize.Height - 2 * $mainform.Padding.Top + $button1.Height + 15))
})
#>

$button1.Add_Click({
    $SelectedClipItem = $listbox.SelectedItem.ToString()
    Rename-Item -Path $SelectedFile -NewName $SelectedClipItem
    $mainform.Close()
})



$mainform.ShowDialog()