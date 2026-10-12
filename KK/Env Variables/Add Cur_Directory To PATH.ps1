#PWSH
[Parameter(Mandatory=$true)]
param(
    [string]$CurDir
)
if (-not $CurDir) {
    $CurDir = $env:CURRENT_DIR
}
$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $admin) {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoExit","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`" -CurDir `"$CurDir`""
    exit
}

$Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Top", "&Bottom" )
$Choices2 = [System.Management.Automation.Host.ChoiceDescription[]] @("&User", "&System" )
$TopBot = $host.UI.PromptForChoice('Add Directory to the Top of the PATH ENV Var, or Bottom to Add Directory To End of PATH env Var', '', $Choices, 1)
$newPath = $CurDir

$UserOrSystem = $host.UI.PromptForChoice('Add Directory to User or System PATH Variables', '', $Choices2, 1)

if ($UserOrSystem -eq 0) {
    # User PATH
    $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment", $true)
}
elseif ($UserOrSystem -eq 1) {
    # System PATH
    $registryKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $true)
}
else {
    Write-Host "You can do it, pick User or System!"
}

# Read the PATH safely without expanding embedded environment variables
$existingPath = $registryKey.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)

$sep = [System.IO.Path]::PathSeparator
$existingPath = ($existingPath -split $sep | Where-Object { $_ -and $_.Trim() }) -join $sep

if ($TopBot -eq 1) {
    $finalPath = "$existingPath$sep$newPath"
    
}
elseif ($TopBot -eq 0) {
    $finalPath = "$newPath$sep$existingPath"
}
else {
    Write-Host "You can do it, pick Top or Bottom!"
}
$registryKey.SetValue('Path', $finalPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
# Clean up the registry handle and display the updated PATH variable in a grid view for confirmation
$updatedPathList = $registryKey.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) -split [System.IO.Path]::PathSeparator
$updatedPathList | Out-GridView -Title "Updated PATH Environment Variable" -Wait
$registryKey.Close()