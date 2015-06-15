Import-Module \\ltc-cleveland\MENU\Powershell\Modules\PSWindowsUpdate

# On Windows 7 / Powershell 2 the module throws a error because the command "Unblock-File" does not exist,
# this does not cause any problems but red text is scary so we clear the screen
cls

$source = Get-WUServiceManager

#foreach ($i in $source) {
    

Write-Host("Installing Windows Updates...")
Get-WUInstall -AcceptAll -AutoReboot -IgnoreUserInput -Verbose
