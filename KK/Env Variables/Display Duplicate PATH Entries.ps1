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

# 4. Find intersections (duplicates present in both User and System paths)
$duplicates = $userPaths | Where-Object { $sysPaths -contains $_ }

# 5. Output results
if ($duplicates) {
    Write-Host "Found $($duplicates.Count) overlapping path(s) between User and System variables:" -ForegroundColor Yellow
    
    $duplicates | ForEach-Object {
        [PSCustomObject]@{
            DuplicatePath = $_
            ExistsIn      = "Both User and System"
        }
    } | Out-GridView -Title "Duplicate PATH Entries" -Wait
} else {
    Write-Host "No overlapping paths found between User and System environments." -ForegroundColor Green
}