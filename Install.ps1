# Installs OC Scripts and PS Scripts that accompany the OC Scripts
# Must Have OneCommander Running While Installing

$DetectedScriptsFolder = ""
$OCEXEDirPath = (Get-Item -Path (Get-Process OneCommander).Path).Directory.FullName
if ($OCEXEDirPath.Contains("WindowsApp")) {
    $DetectedScriptsFolder = "$Env:USERPROFILE\OneCommander\Resources\Scripts\"
}
elseif ($OCEXEDirPath.Contains("Program Files")) {
    $DetectedScriptsFolder = "$Env:LOCALAPPDATA\OneCommander\Resources\Scripts\"
}
else {
$DetectedScriptsFolder = "$OCEXEDirPath\Resources\Scripts\"
}
$KPCResourcePath = "$DetectedScriptsFolder\..\KPC\"
taskkill.exe /IM "adb.exe" /F
New-Item -Path $DetectedScriptsFolder -ItemType Directory -Force
New-Item -Path $KPCResourcePath -ItemType Directory -Force
Copy-Item -Recurse -Path  "$PSScriptRoot\KPC\" -Destination $DetectedScriptsFolder -Force
Copy-Item -Recurse -Path "$PSScriptRoot\OC\*" -Destination $KPCResourcePath -Force
$Path = Join-Path $DetectedScriptsFolder "..\KPC\Export\"
New-Item -Path $Path -ItemType Directory -Force
$OCSettingsPath = "$OCEXEDirPath\Settings\"
$OCProfilePath = "$OCSettingsPath\OneCommanderProfile.ps1"
if (!(Test-Path $OCProfilePath)) {
    New-Item -Path $OCProfilePath -ItemType File -Value "#This is the begining of the OneCommanderProfile.ps1" -Force
}
else {
$OCProfilePathContents = Get-Content -Path $OCProfilePath -Raw
}
$RawProfileContent = @'
#KPC-Integrations Script Pack For OneCommander Profile Code...don't remove this unless you want to reinstall after breaking the scripts(some).
if (Test-Path -Path "$PathCusPSVars.xml") {
$CustomVariables = Import-Clixml -Path "$PathCusPSVars.xml"
$CustomVariables.GetEnumerator() | ForEach-Object -Process { New-Variable -Name $_.Name -Value $_.Value -Option AllScope -Scope Global -Force }
}
if ($null -eq $CustomVariables) {
    $example = @{}
    $example.Add("ExampleVarPath","C:\Windows\System32\drivers\etc\")
    $example | Export-Clixml -Path "$Path\CusPSVars.xml" -Force
}
. "$PSSCriptRoot\..\Resources\KPC\Invoke-SharedFunctions.ps1"
'@
$RawProfileParsed = $RawProfileContent.Replace('$Path',$Path)

if ($OCProfilePathContents -notcontains $RawProfileParsed) {
    Add-Content -Path $OCProfilePath -Value ""
    Add-Content -Path $OCProfilePath -Value $RawProfileParsed
    }

$OCProfileContent = @'
. "$DetectedScriptsFolder\..\..\Settings\OneCommanderProfile.ps1"
'@    
$OCProfileContentParsed = $OCProfileContent.Replace('$DetectedScriptsFolder',$DetectedScriptsFolder)
if ($PROFILE -notcontains $OCProfileContent) {
    Add-Content -Path $PROFILE -Value $OCProfileContentParsed
    $PS7PROFILE = $PROFILE.Replace("WindowsPowerShell","PowerShell")
    Add-Content -Path $PS7PROFILE -Value $OCProfileContentParsed
}


$AlteredScriptExecutorsJson = @'
[
  {
    "Executable": "powershell.exe",
    "HeaderTags": "#PS",
    "Extensions": "ps1",
    "Arguments": "-NoExit -File \"SCRIPT_PATH\""
  },
  {
    "Executable": "pwsh.exe",
    "HeaderTags": "#PS7,#PWSH",
    "Extensions": "ps1",
    "Arguments": "-NoExit -File \"SCRIPT_PATH\""
  },
  {
    "Executable": "wt.exe",
    "HeaderTags": "#WT",
    "Extensions": "ps1",
    "Arguments": "powershell -NoExit -File \"SCRIPT_PATH\""
  },
  {
    "Executable": "python.exe",
    "HeaderTags": "#PY,#PYTHON",
    "Extensions": "py",
    "Arguments": "\"SCRIPT_PATH\""
  },
  {
    "Executable": "cmd.exe",
    "HeaderTags": "#CMD",
    "Extensions": "bat",
    "Arguments": "/K \"SCRIPT_PATH\""
  }
]
'@
$FinSEJson = $AlteredScriptExecutorsJson.Replace('$OCProfilePath',$OCProfilePath)
Set-Content "$OCSettingsPath\ScriptExecutors.json" -Value $FinSEJson -Force

#. "$KPCResourcePath\Update-Tools.ps1"