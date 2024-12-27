[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [string]
    $Title,

    [Parameter(Position=1)]
    [string]
    $PromptText,

    [Parameter(Position=2)]
    [string]
    $ButtonsType = "YesNoCancel",

    [Parameter(Position=3)]
    [string]
    $IconType = "Question"
)
Add-Type -AssemblyName System.Windows.Forms
$MBResults = [System.Windows.Forms.MessageBox]::Show($PromptText, $Title, [System.Windows.Forms.MessageBoxButtons]::$ButtonsType, [System.Windows.Forms.MessageBoxIcon]::$IconType)

return $MBResults

