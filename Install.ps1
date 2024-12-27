# Installs OC Scripts and PS Scripts that accompany the OC Scripts
# Must Have OneCommander Running While Installing
Add-Type -AssemblyName System.Windows.Forms
if (!(Get-Command wt.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults = & "$PSScriptRoot\OC\Show-CustomDialog.ps1" -Title "Install Terminal?" -PromptText "Windows Terminal is NOT installed. Install Now?" -ButtonsType "YesNo" -IconType "Question"
    if ($MBResults -eq [System.Windows.Forms.DialogResult]::Yes) {
    winget install Microsoft.WindowsTerminal --scope machine --silent
    }
    else {
        Write-Host "Not Installing Windows Terminal..."
    }
}
else {
    Write-Host "WT Already Installed"
}
if (!(Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults2 = & "$PSScriptRoot\OC\Show-CustomDialog.ps1" -Title "Install PS7?" -PromptText "PS7.4+ is required for this script pack but it not installed...please select ok to install or cancell to quit installation of this script pack!" -ButtonsType "OkCancel" -IconType "Exclamation"
    if ($MBResults2 -eq [System.Windows.Forms.DialogResult]::OK) {
    winget install Microsoft.PowerShell --scope machine --silent
    }
    else {
        break
    }
    
}
else {
    Write-Host "PowerShell 7 Already Installed"
}
$ParseOCPath = ""
$OCPath = (Get-Process OneCommander).Path
if ($OCPath.Contains("WindowsApp")) {
    $ParseOCPath = "$Env:USERPROFILE\OneCommander\Resources\Scripts\"
}
elseif ($OCPath.Contains("Program Files")) {
    $ParseOCPath = "$Env:LOCALAPPDATA\OneCommander\Resources\Scripts\"
}
else {
$ParseOCPath = (Get-Item -LiteralPath $OCPath).Directory.FullName + '\Resources\Scripts\'
}
$ParseParseOCPath = ($ParseOCPath | Join-Path -ChildPath "..\KPC\")
taskkill.exe /IM "adb.exe" /F
New-Item -Path $ParseOCPath -ItemType Directory -Force
New-Item -Path $ParseParseOCPath -ItemType Directory -Force
Copy-Item -Recurse -Path  "$PSScriptRoot\KPC\" -Destination $ParseOCPath -Force
Copy-Item -Recurse -Path "$PSScriptRoot\OC\*" -Destination $ParseParseOCPath -Force
. "$ParseParseOCPath\Invoke-OCInit.ps1"