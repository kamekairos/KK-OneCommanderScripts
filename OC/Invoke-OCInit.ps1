New-Item -Path "$PSScriptRoot\Export\" -ItemType Directory -Force
$Path = "$PSScriptRoot\Export\"
$OCPROFILEPATH = Join-Path (Get-Item ((Get-Command OneCommander.exe).Path)).Directory '\Settings\OneCommanderProfile.ps1'
if (Test-Path $OCPROFILEPATH) {
$OCPROFILEPATHContents = Get-Content -Path $OCPROFILEPATH -Raw
}
else{
    New-Item -Path $OCPROFILEPATH -ItemType File -Value "#This is the beginning of the OCPROFILE file..."
    $OCPROFILEPATHContents = Get-Content -Path $OCPROFILEPATH -Raw
}
$RawProfileContent = @'
#KPC-Integrations Script Pack For OneCommander Profile Code...don't remove this unless you want to reinstall after breaking the scripts(some).
if (Test-Path -Path $Path\CusPSVars.xml) {
$CustomVariables = Import-Clixml -Path "$Path\CusPSVars.xml"
$CustomVariables.GetEnumerator() | ForEach-Object -Process { New-Variable -Name $_.Name -Value $_.Value -Option AllScope -Scope Global -Force }
}
else {
    $example = @{}
    $example.Add("ExampleVarPath","C:\Windows\System32\drivers\etc\")
    $example | Export-Clixml -Path "$Path\CusPSVars.xml" -Force
}
$OCPath = (Get-Process OneCommander | Select-Object -First 1).Path
if ($OCPath.Contains('WindowsApp')) {
    $ParseOCPath = (Join-Path $Env:USERPROFILE '\OneCommander\')
}
elseif ($OCPath.Contains('Program Files')) {
    $ParseOCPath = (Join-Path $Env:LOCALAPPDATA '\OneCommander\')
}
else {
$ParseOCPath = (Get-Item -LiteralPath $OCPath).Directory.FullName
}
. "$ParseOCPath\Resources\KPC\Invoke-SharedFunctions.ps1"
'@
$RawProfileParsed = $RawProfileContent.Replace('$Path',$Path)

if (!($OCPROFILEPATHContents.Contains($RawProfileParsed))) {
    Add-Content -Path $OCPROFILEPATH -Value ""
    Add-Content -Path $OCPROFILEPATH -Value $RawProfileParsed
    }
. "$PSScriptRoot\Update-Tools.ps1"
