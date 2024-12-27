$platformToolsUpdateUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
Invoke-RestMethod -Uri $platformToolsUpdateUrl -OutFile "$env:TEMP\platform-tools.zip"
Expand-Archive -Path "$env:TEMP\platform-tools.zip" -DestinationPath "$env:TEMP\platform-tools\"
Get-ChildItem -Path "$env:TEMP\platform-tools\*adb*" | Copy-Item -Destination "$PSScriptRoot\Tools\"
