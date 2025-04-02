#PS7
$Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Top", "&Bottom" )
$TopBot = $host.UI.PromptForChoice('Add Directory to the Top of the PATH ENV Var, or Bottom to Add Directory To End of PATH env Var', '', $Choices, 1)
$CurDir = $env:CURRENT_DIR
$newPath = $CurDir

$envPath = 'HKCU:\Environment'
$key = Get-Item -Path $envPath
$existingPath = $key.GetValue('PATH', '', 'DoNotExpandEnvironmentNames')
$key.Dispose()

if($TopBot -eq 1) {
$newParams = @{
    Path         = $envPath
    Name         = 'PATH'
    Value        = "$existingPath$([System.IO.Path]::PathSeparator)$newPath"
    PropertyType = 'ExpandString'
    Force        = $true
}
}
elseif ($TopBot -eq 0) {
    $newParams = @{
        Path         = $envPath
        Name         = 'PATH'
        Value        = "$newPath$([System.IO.Path]::PathSeparator)$existingPath"
        PropertyType = 'ExpandString'
        Force        = $true
    }
}
else {
    Write-Host "You can do it, pick Top or Bottom!"
}
New-ItemProperty @newParams | Out-Null