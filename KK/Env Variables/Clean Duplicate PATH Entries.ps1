#PWSH
$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $admin) {
    Write-Host $PSCommandPath
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoExit","-ExecutionPolicy","Bypass","-File",`"$PSCommandPath`"
    exit
}

$regUser = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment",$true)
$regSystem = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("System\CurrentControlSet\Control\Session Manager\Environment", $true)

$rawUserPath   = $regUser.GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::None)
$rawSystemPath = $regSystem.GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::None)

$parsedUserPaths = ($rawUserPath -split ';' | Select-Object -Unique) -join ';'
$parsedSystemPaths = ($rawSystemPath -split ';' | Select-Object -Unique) -join ';'

$regUser.SetValue('PATH', $parsedUserPaths, [Microsoft.Win32.RegistryValueKind]::ExpandString)
$regSystem.SetValue('PATH', $parsedSystemPaths, [Microsoft.Win32.RegistryValueKind]::ExpandString)

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



$duplicates = $userPaths | Where-Object { $sysPaths -contains $_ }

# 5. Output results
if ($duplicates) {
    $promptfordupes = $true
    Write-Host "Found $($duplicates.Count) overlapping path(s) between User and System variables:" -ForegroundColor Yellow
    
    $duplicates | ForEach-Object {
        [PSCustomObject]@{
            DuplicatePath = $_
            ExistsIn      = "Both User and System"
        }
    } | Format-Table -AutoSize
} else {
    Write-Host "No overlapping paths found between User and System environments." -ForegroundColor Green
    $promptfordupes = $false
}
if ($promptfordupes) {
$removedupes = Read-host -Prompt "Would You Like To Remove These Duplicates From The User PATH Variable? (Y/N)"
}
if ($removedupes -eq 'Y' -or $removedupes -eq 'y') {
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&User", "&System" )
    $userorsytem = $host.UI.PromptForChoice('Remove Duplicates From User or System PATH Variables', '', $Choices, 1)
    if ($userorsytem -eq 0) {
        # Remove duplicates from User PATH
        $cleanedUserPaths = $userPaths | Where-Object { $duplicates -notcontains $_ }
        $newUserPath = ($cleanedUserPaths -join ';').TrimEnd(';')

        # Write back to the registry
        $regUser = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment", $true)
        $regUser.SetValue('PATH', $newUserPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        $regUser.Close()

        Write-Host "Duplicates removed from User PATH variable." -ForegroundColor Green
    }
    elseif ( $userorsytem -eq 1 ) {
        # Remove duplicates from System PATH
        $cleanedSysPaths = $sysPaths | Where-Object { $duplicates -notcontains $_ }
        $newSysPath = ($cleanedSysPaths -join ';').TrimEnd(';')

        # Write back to the registry
        $regSystem = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $true)
        $regSystem.SetValue('PATH', $newSysPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        $regSystem.Close()

        Write-Host "Duplicates removed from System PATH variable." -ForegroundColor Green
    }
    } else {
        Write-Host "No changes made to PATH variables." -ForegroundColor Cyan
    }