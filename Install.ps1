# Installs OC Scripts and PS Scripts that accompany the OC Scripts
# Must Have OneCommander Running While Installing

$ParseOCPath = ""
$OCPath = (Get-Process OneCommander).Path
if ($OCPath.Contains("WindowsApp")) {
    $ParseOCPath = "$Env:USERPROFILE\OneCommander\Resources\Scripts\"
}
elseif ($OCPath.Contains("Program Files")) {
    $ParseOCPath = "$Env:LOCALAPPDATA\OneCommander\Resources\Scripts\"
}
else {
$ParseOCPath = (Get-Item -LiteralPath $OCPath).Directory.FullName + '\Resources\Scripts\'
}
$ParseParseOCPath = ($ParseOCPath | Join-Path -ChildPath "..\KPC\")
taskkill.exe /IM "adb.exe" /F
New-Item -Path $ParseOCPath -ItemType Directory -Force
New-Item -Path $ParseParseOCPath -ItemType Directory -Force
Copy-Item -Recurse -Path  "$PSScriptRoot\KPC\" -Destination $ParseOCPath -Force
Copy-Item -Recurse -Path "$PSScriptRoot\OC\*" -Destination $ParseParseOCPath -Force
. "$ParseParseOCPath\Invoke-OCInit.ps1"