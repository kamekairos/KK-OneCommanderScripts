Add-Type -AssemblyName System.Windows.Forms

# Refresh process PATH from Registry
function Update-SessionEnvironment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + 
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# 1. Check Windows Terminal
if (-not (Get-Command wt.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults = & "$PSScriptRoot\OC\SharedScripts\Show-CustomDialog.ps1" `
        -Title "Install Terminal?" `
        -PromptText "Windows Terminal is NOT installed. Install Now?" `
        -ButtonsType "YesNo" `
        -IconType "Question"

    if ($MBResults -eq [System.Windows.Forms.DialogResult]::Yes) {
        winget install --id Microsoft.WindowsTerminal --exact --accept-source-agreements --accept-package-agreements
        Update-SessionEnvironment
    } else {
        Write-Host "Skipping Windows Terminal installation."
    }
} else {
    Write-Host "Windows Terminal already installed."
}

# 2. Check PowerShell 7+
if (-not (Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    $MBResults2 = & "$PSScriptRoot\OC\SharedScripts\Show-CustomDialog.ps1" `
        -Title "Install PS7+ ?" `
        -PromptText "PowerShell 7+ is required for this script pack. Select OK to install or Cancel to abort." `
        -ButtonsType "OkCancel" `
        -IconType "Exclamation"

    if ($MBResults2 -eq [System.Windows.Forms.DialogResult]::OK) {
        winget install --id Microsoft.PowerShell --exact --accept-source-agreements --accept-package-agreements
        Update-SessionEnvironment
    } else {
        Write-Warning "Aborting Installation: PowerShell 7 is required."
        exit 1
    }
} else {
    Write-Host "PowerShell 7 already installed."
}

# 3. Chain into Install.ps1
& "$PSScriptRoot\Install.ps1"