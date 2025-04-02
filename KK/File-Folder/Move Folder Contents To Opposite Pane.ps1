#PS7
$SelectedFolder = $Env:CURRENT_DIR
$opDir = $Env:Current_Dir_Inactive
Move-Item -Path "$SelectedFolder\*" -Destination $opDir