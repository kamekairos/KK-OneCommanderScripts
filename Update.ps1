<#
.SYNOPSIS
    Quickly updates OneCommander KK Script Pack files during development.
.DESCRIPTION
    Locates OneCommander's UserResources folder via running process (or optional parameter)
    and updates the latest scripts from the repository's KK and OC folders without first-time install overhead.
.PARAMETER UserResourcesPath
    Optional manual path to OneCommander's UserResources directory.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$UserResourcesPath
)

# 1. Locate OneCommander UserResources Path
if (-not $UserResourcesPath) {
    $OCProcess = Get-Process -Name OneCommander -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $OCProcess) {
        Write-Error -Message "OneCommander is not running. Please launch OneCommander and rerun this script."
        exit 1
    }

    $OCEXEDirPath = (Get-Item -Path $OCProcess.Path).Directory.FullName
    $UserResourcesPath = Join-Path -Path $OCEXEDirPath -ChildPath "UserResources"
}

if (-not (Test-Path -Path $UserResourcesPath)) {
    Write-Error -Message "Target UserResources folder not found: $UserResourcesPath"
    exit 1
}

Write-Host "OneCommander UserResources: $UserResourcesPath" -ForegroundColor Cyan

# 2. Establish Target Paths
$ScriptsTarget    = Join-Path -Path $UserResourcesPath -ChildPath "Scripts\KK"
$KKResourceTarget = Join-Path -Path $UserResourcesPath -ChildPath "KK"
$ExportTarget     = Join-Path -Path $KKResourceTarget -ChildPath "Export"

# 3. Ensure Target Directories Exist
$null = New-Item -Path $ScriptsTarget -ItemType Directory -Force
$null = New-Item -Path $KKResourceTarget -ItemType Directory -Force
$null = New-Item -Path $ExportTarget -ItemType Directory -Force

# 4. Deploy Script Files (repo KK -> UserResources\Scripts\KK)
$KKSource = Join-Path -Path $PSScriptRoot -ChildPath "KK"
if (Test-Path -Path $KKSource) {
    Copy-Item -Path "$KKSource\*" -Destination $ScriptsTarget -Recurse -Force
    Write-Host "  [+] Updated Script Menu files -> $ScriptsTarget" -ForegroundColor Green
} else {
    Write-Warning -Message "Source directory not found: $KKSource"
}

# 5. Deploy OC Files (repo OC -> UserResources\KK)
$OCSource = Join-Path -Path $PSScriptRoot -ChildPath "OC"
if (Test-Path -Path $OCSource) {
    Copy-Item -Path "$OCSource\*" -Destination $KKResourceTarget -Recurse -Force
    Write-Host "  [+] Updated Shared/Backend files -> $KKResourceTarget" -ForegroundColor Green
} else {
    Write-Warning -Message "Source directory not found: $OCSource"
}

Write-Host "Update completed successfully." -ForegroundColor Green
