#PWSH
# 1. Fetch raw PATH strings directly from Registry targets to isolate User vs System
$regUser   = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment")
$regSystem = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("System\CurrentControlSet\Control\Session Manager\Environment")

$rawUserPath   = $regUser.GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::None)
$rawSystemPath = $regSystem.GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::None)

$regUser.Close()
$regSystem.Close()

# 2. Expand embedded environment variables (e.g., %USERPROFILE%, %SystemRoot%)
$expandedUser   = [System.Environment]::ExpandEnvironmentVariables($rawUserPath)
$expandedSystem = [System.Environment]::ExpandEnvironmentVariables($rawSystemPath)

# 3. Split into arrays, trim whitespace, and clean up trailing slashes for accurate comparison
$userPaths = $expandedUser -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim().TrimEnd('\') }
$sysPaths  = $expandedSystem -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim().TrimEnd('\') }

$UorS = $host.UI.PromptForChoice('Display User or System PATH entries?', '', [System.Management.Automation.Host.ChoiceDescription[]] @("&User", "&System", "&Both"), 0)

if ($UorS -eq 0) {
    # Display User PATH entries
    $paths = $userPaths
} elseif ($UorS -eq 1) {
    # Display System PATH entries
    $paths = $sysPaths
} elseif ($UorS -eq 2) {
    # Display Both PATH entries
    $paths = $userPaths + $sysPaths
}

$paths | Sort-Object | Out-GridView -Title "PATH Entries" -Wait