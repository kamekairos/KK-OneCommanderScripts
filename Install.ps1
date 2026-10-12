# Installs OC Scripts and PS Scripts that accompany the OC Scripts
# Must Have OneCommander Running While Installing

# 1. Locate OneCommander Process Safely
$OCProcess = Get-Process -Name OneCommander -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $OCProcess) {
    Write-Error -Message "OneCommander is not running. Please launch OneCommander and rerun this script."
    exit 1
}

$OCEXEDirPath = (Get-Item -Path $OCProcess.Path).Directory.FullName

# 2. Establish Paths
$ResourcesFolder = Join-Path -Path $OCEXEDirPath -ChildPath "UserResources"
$ScriptsPath        = Join-Path -Path $ResourcesFolder -ChildPath "Scripts"
$KKResourcePath        = Join-Path -Path $ResourcesFolder -ChildPath "KK"
$Path                  = (Join-Path -Path $KKResourcePath -ChildPath "Export").TrimEnd('\')

# 3. Kill ADB and Initialize Directory Tree
taskkill.exe /IM "adb.exe" /F 2> $null

# Deploy Script Packs
Copy-Item -Path "$PSScriptRoot\KK\" -Destination $ScriptsPath -Recurse -Force
Copy-Item -Path "$PSScriptRoot\OC\" -Destination "$ResourcesFolder\KK\" -Recurse -Force

New-Item -Path $Path -ItemType Directory -Force | Out-Null

# 4. Configure OneCommanderProfile.ps1
$OCSettingsPath = Join-Path -Path $OCEXEDirPath -ChildPath "Settings"
$OCProfilePath  = Join-Path -Path $OCSettingsPath -ChildPath "OneCommanderProfile.ps1"

if (-not (Test-Path -Path $OCProfilePath)) {
    New-Item -Path $OCProfilePath -ItemType File -Value "# This is the beginning of the OneCommanderProfile.ps1`r`n" -Force | Out-Null
}

$OCProfilePathContents = Get-Content -Path $OCProfilePath -Raw -ErrorAction SilentlyContinue

$RawProfileContent = @'
#KK-Integrations Script Pack For OneCommander Profile Code...don't remove this unless you want to reinstall after breaking the scripts(some).
if (Test-Path -Path "$Path\CusPSVars.xml") {
    $CustomVariables = Import-Clixml -Path "$Path\CusPSVars.xml"
    $CustomVariables.GetEnumerator() | ForEach-Object -Process { New-Variable -Name $_.Name -Value $_.Value -Option AllScope -Scope Global -Force }
}
if ($null -eq $CustomVariables) {
    $example = @{}
    $example.Add("ExampleVarPath", "C:\Windows\System32\drivers\etc\")
    $example | Export-Clixml -Path "$Path\CusPSVars.xml" -Force
}
. "$KKResourcePath\Invoke-SharedFunctions.ps1"
'@

# Replace template path variables while maintaining runtime single-quote scoping
$RawProfileParsed = $RawProfileContent.Replace('$Path', $Path).Replace('$KKResourcePath', $KKResourcePath)

if ($OCProfilePathContents -notmatch [regex]::Escape($RawProfileParsed)) {
    Add-Content -Path $OCProfilePath -Value "`r`n$RawProfileParsed"
}

# 5. Link OneCommander Profile to Windows PowerShell & PowerShell 7+ Profiles
$OCProfileContent = @'
. "$OCProfilePath"
'@
$OCProfileContentParsed = $OCProfileContent.Replace('$OCProfilePath', $OCProfilePath)

$ProfilesToUpdate = @(
    $PROFILE, $PROFILE.Replace("WindowsPowerShell", "PowerShell")
)

foreach ($Prof in $ProfilesToUpdate) {
    $ProfDir = Split-Path -Path $Prof -Parent
    
    if (-not (Test-Path -Path $ProfDir)) {
        New-Item -Path $ProfDir -ItemType Directory -Force | Out-Null
    }
    
    if (-not (Test-Path -Path $Prof)) {
        New-Item -Path $Prof -ItemType File -Force | Out-Null
    }

    $ProfDiskContents = Get-Content -Path $Prof -Raw -ErrorAction SilentlyContinue
    
    if ($ProfDiskContents -notmatch [regex]::Escape($OCProfileContentParsed)) {
        Add-Content -Path $Prof -Value "`r`n$OCProfileContentParsed"
        Write-Host -Object "PowerShell profile updated: $Prof"
    } else {
        Write-Host -Object "PowerShell profile already contains OneCommanderProfile.ps1 reference: $Prof"
    }
}

$ScriptExecutorsPath = Join-Path -Path $OCSettingsPath -ChildPath "ScriptExecutors.json"
$ScriptExecutorsContent = Get-Content -Path $ScriptExecutorsPath -Raw -ErrorAction SilentlyContinue
$SciptExecutorsContentParsed = $ScriptExecutorsContent.Replace('-NoProfile','')
Set-Content -Path $ScriptExecutorsPath -Value $SciptExecutorsContentParsed -Force
# 6. Optional Tool Updates
Write-Host "If your installing for the first time, you should update these tools, as that the only way to install them inititally without reinstalling everything!"
$UpdateTools = $host.UI.PromptForChoice("Update Tool Utilities and Libraries Now? (Y/N)", "", @("&Yes", "&No"), 0)

if ($UpdateTools -eq 0) {
    $ToolsDir = Join-Path -Path $KKResourcePath -ChildPath "Tools"
    New-Item -Path $ToolsDir -ItemType Directory -Force | Out-Null

    $adbCmd = Get-Command -Name adb -ErrorAction SilentlyContinue
    
    if ($adbCmd) {
        Write-Host -Object "ADB Detected on System PATH... Skipping ADB Install"
        $testADB = $true
        Copy-Item -Path $adbCmd.Path -Destination (Join-Path -Path $ToolsDir -ChildPath "adb.exe") -Force
    } else {
        $testADB = $false
    }

    $aapt2Cmd = Get-Command -Name aapt2 -ErrorAction SilentlyContinue
    
    if ($aapt2Cmd) {
        Write-Host -Object "Aapt2 Detected on System PATH... Skipping Install"
        $Script:testAapt2 = $true
    } else {
        $Script:testAapt2 = $false
    }

    $UpdateToolsScript = Join-Path -Path $KKResourcePath -ChildPath "Update-Tools.ps1"
    
    if (Test-Path -Path $UpdateToolsScript) {
        & $UpdateToolsScript -SkipADB $testADB -SkipAAPT2 $Script:testAapt2
    } else {
        Write-Warning -Message "Update-Tools.ps1 not found at: $UpdateToolsScript"
    }
} else {
    Write-Host -Object "Skipping Tools Update..."
}