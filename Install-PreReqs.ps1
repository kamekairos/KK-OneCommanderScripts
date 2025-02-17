Add-Type -AssemblyName System.Windows.Forms
if (!(Get-Command wt.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults = & "$PSScriptRoot\OC\Show-CustomDialog.ps1" -Title "Install Terminal?" -PromptText "Windows Terminal is NOT installed. Install Now?" -ButtonsType "YesNo" -IconType "Question"
    if ($MBResults -eq [System.Windows.Forms.DialogResult]::Yes) {
    winget install Microsoft.WindowsTerminal
    }
    else {
        Write-Host "Not Installing Windows Terminal..."
    }
}
else {
    Write-Host "WT Already Installed"
}
if (!(Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults2 = & "$PSScriptRoot\OC\Show-CustomDialog.ps1" -Title "Install PS7+ ?" -PromptText "PS7+ is required for this script pack but it not installed...please select ok to install or cancell to quit installation of this script pack!" -ButtonsType "OkCancel" -IconType "Exclamation"
    if ($MBResults2 -eq [System.Windows.Forms.DialogResult]::OK) {
    winget install Microsoft.PowerShell
    }
    else {
        Write-Host "Aborting Installation!"
        break
    }
}
else {
    Write-Host "PowerShell 7 Already Installed"
}
$scriptroot = $PSScriptRoot
powershell.exe -NoExit -NoProfile -Command {
    param (
    [string]
    $ScriptRootPar
    )
    powershell.exe -NoExit -File "$ScriptRootPar\Install.ps1"} -Args $scriptroot