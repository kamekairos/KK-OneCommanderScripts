$platformToolsUpdateUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
Invoke-RestMethod -Uri $platformToolsUpdateUrl -OutFile "$env:TEMP\platform-tools.zip"
Expand-Archive -Path "$env:TEMP\platform-tools.zip" -DestinationPath "$env:TEMP\platform-tools\" -Force
Get-ChildItem -Path "$env:TEMP\platform-tools\*adb*" | Copy-Item -Destination "$PSScriptRoot\Tools\" -Force

$NETSDKRefUpdateUrl = "https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.NET.Ref"
Invoke-RestMethod -Uri $NETSDKRefUpdateUrl -OutFile "$env:TEMP\Microsoft.Windows.SDK.NET.Ref.nupackage"
Expand-Archive -Path "$env:TEMP\Microsoft.Windows.SDK.NET.Ref.nupackage" -DestinationPath "$env:TEMP\Microsoft.Windows.SDK.NET.Ref\" -Force
Get-ChildItem -Path "$env:TEMP\Microsoft.Windows.SDK.NET.Ref\lib\net8.0\Microsoft.Windows.SDK.NET.dll" | Copy-Item -Destination "$PSScriptRoot\Tools\" -Force

$AAPT2TarUrl = "https://android.googlesource.com/platform/prebuilts/sdk/+archive/refs/heads/main/tools/windows/bin.tar.gz"
Invoke-WebRequest -Uri $AAPT2TarUrl -OutFile "$env:TEMP\prebuilttools.tar.gz"
$SRB4 = $PSScriptRoot
Set-Location $env:TEMP
tar -xf "$env:TEMP\prebuilttools.tar.gz"
Copy-Item -Path "$env:TEMP\aapt2.exe" -Destination "$SRB4\Tools\aapt2.exe" -Force