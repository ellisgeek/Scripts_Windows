#Target location or program
$Target = "https://gotoltc.blackboard.com"
$Description = "Launch LTC Blackboard"
$Icon = "\\ltc-cleveland\menu\Powershell\Icons\Blackboard.ico"


foreach ($user in (Get-ChildItem C:\Users)) {
    Write-Host("Creating shortcut to $Target on $($user)'s Desktop")
    $Shell = New-Object -comObject WScript.Shell
    $Link = $Shell.CreateShortcut((Join-Path (Join-Path "C:\Users" $user) "/Desktop/Blackboard.lnk"))
    $Link.TargetPath = $Target
    $Link.Description = $Description
    $Link.IconLocation = $Icon
    $Link.Save()
}