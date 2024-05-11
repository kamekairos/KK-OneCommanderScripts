New-Item -Path "$PSScriptRoot\Export\" -ItemType Directory -Force
$Path = "$PSScriptRoot\Export\"
$ProfileContents = Get-Content -Path $PROFILE -Raw
$RawProfileContent = @'
if (Test-Path -Path $Path\CusPSVars.xml) {
$CustomVariables = Import-Clixml -Path "$Path\CusPSVars.xml"
$CustomVariables.GetEnumerator() | ForEach-Object -Process { New-Variable -Name $_.Name -Value $_.Value -Option AllScope -Scope Global -Force }
}
else {
    $example = @{}
    $example.Add("ExampleVarPath","C:\Windows\System32\drivers\etc\")
    $example | Export-Clixml -Path "$Path\CusPSVars.xml" -Force
}
$OCPath = (Get-Process OneCommander).Path
if ($OCPath.Contains('WindowsApp')) {
    $ParseOCPath = (Join-Path $Env:USERPROFILE '\OneCommander\')
}
elseif ($OCPath.Contains('Program Files')) {
    $ParseOCPath = (Join-Path $Env:LOCALAPPDATA '\OneCommander\')
}
else {
$ParseOCPath = (Get-Item -LiteralPath $OCPath).Directory.FullName
}
. (Join-Path $ParseOCPath 'Resources\KPC\Invoke-SharedFunctions.ps1')
'@
$RawProfileParsed = $RawProfileContent.Replace('$Path',$Path)

if (Test-Path $PROFILE) {
    if (!($ProfileContents.Contains($RawProfileParsed))) {
Add-Content -Path $PROFILE -Value ""
Add-Content -Path $PROFILE -Value $RawProfileParsed
    }
}
else {
    New-Item -Path $PROFILE -Value $null -ItemType File -Force
    if ($ProfileContents -notcontains $RawProfileParsed) {
    Add-Content -Path $PROFILE -Value ""
Add-Content -Path $PROFILE -Value $RawProfileParsed
    }
}