$newline = [Environment]::NewLine

#$mail = @{}

$system = (Get-WmiObject -Class Win32_ComputerSystem)
$cpu = (Get-WmiObject -Class Win32_Processor)
$memory = (Get-WMIObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)})
$productNumber = (Get-WmiObject -Namespace root\wmi  -Class MS_SystemInformation) | Select SystemSKU
$disk = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Measure-Object -Property Size -Sum | % {[Math]::Round(($_.sum / 1GB),2)})
$enclosure = (Get-WmiObject -Class Win32_SystemEnclosure)
$activeAdapters = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE | Select Description,IPAddress, MACAddress)

$query = "SELECT * FROM ds_user where ds_sAMAccountName='$env:username'"
$user = Get-WmiObject -Query $query -Namespace "root\Directory\LDAP"
If([string]::IsNullOrEmpty($user.DS_mail)) {
    $from = $user.DS_userPrincipalName
} Else {$from = $user.DS_mail}

Function Ask-ForInput($message="Please enter some Text") {
    While($true){
        $input = Read-Host $message
        Write-Host("You entered: ") -f DarkCyan -NoNewline; Write-Host($input) -f DarkYellow
        $yn = Read-Host "Is this correct? (Yes/[No])" 
        If(($yn.ToLower() -eq "y") -or ($yn.ToLower() -eq "yes")){
            Return($input)
            Break
        }
    }
}

Function Write-Centered {
    Param(  [string] $message,
            [string] $color = "black")
    $offsetvalue = [Math]::Round(([Console]::WindowWidth / 2) + ($message.Length / 2))
    Write-Host ("{0,$offsetvalue}" -f $message) -ForegroundColor $color
}

$body =  "<ul>{0}" -f $newline
$body += "  <li><b>Computer Name:</b> {0}</li>{1}" -f $system.Name, $newline
$body += "  <li><b>Manufacturer:</b> {0}</li>{1}" -f $system.Manufacturer, $newline
$body += "  <li><b>Model:</b> {0}</li>{1}" -f $system.Model, $newline
$body += "  <ul>{1}    <li><b>Product Number:</b> {0}</li>{1}  </ul>{1}" -f $productNumber.SystemSKU, $newline
$body += "  <li><b>Serial Number:</b> {0}</li>{1}" -f $enclosure.SerialNumber, $newline
if(($enclosure.SMBIOSAssetTag -notmatch $enclosure.SerialNumber) -and ( -not [string]::IsNullOrEmpty($enclosure.SMBIOSAssetTag))) {
    $asset = $enclosure.SMBIOSAssetTag
} Else {
    Write-Host("Unfortunately we could not automattically get the asset tag for your computer.") -f Gray
    Write-Host("")
    Write-Host("The asset tag should be a small ") -f Gray -NoNewline;Write-Host("white ") -f White -NoNewline;Write-Host("sticker with a ") -f Gray -NoNewline;Write-Host("barcode ") -f DarkYellow -NoNewline;Write-Host("and ") -f Gray -NoNewline;Write-Host("6 ") -f DarkYellow -NoNewline;Write-Host("numbers{0}below it." -f $newline) -f Gray
    Write-Host("")
    Write-Host("If you have a Laptop you can find the sticker on the ") -f Gray -NoNewline;Write-Host("Top ") -f DarkYellow -NoNewline;Write-Host("of your Laptop.") -f Gray
    Write-Host("If you have a Desktop your asset tag willl be on the ") -f Gray -NoNewline;Write-Host("Front") -f DarkYellow -NoNewline;Write-Host(", ") -f Gray -NoNewline;Write-Host("Top") -f DarkYellow -NoNewline;Write-Host(", or ") -f Gray -NoNewline;Write-Host("Left Side") -f DarkYellow;
    Write-Host("of your PC.") -f Gray
    Write-Host("")
    Write-Host("If you are unable to locate your asset tag please call Computer Services at{0}extension " -f $newline) -f Gray -NoNewline;Write-Host("#1710") -f DarkYellow -NoNewline;Write-Host -f Gray
    Write-Host("")
    Write-Host("")
    $asset = Ask-ForInput("Please enter the asset tag for your computer")
}
$body += "  <li><b>Asset Tag:</b> {0}</li>{1}" -f $asset, $newline
$body += "  <li><b>Processor:</b> {0}</li>{1}" -f $cpu.Name, $newline
$body += "  <li><b>Memory:</b> {0} GB</li>{1}" -f $memory, $newline
$body += "  <li><b>HDD:</b> {0} GB</li>{1}" -f $disk, $newline
$body += "  <li><b>Network Adapters:</b></li>{0}"  -f $newline
$body += "  <ul>{0}" -f $newline
ForEach($adapter in $activeAdapters){
    If($adapter.Description -Like "VMware Virtual Ethernet Adapter*"){}
    Else{
        $body += "    <li>{0}</li>{1}" -f $adapter.Description, $newline
        $body += "    <ul>{0}" -f $newline
        $body += "      <li><b>IP Address(s):</b></li>{0}"  -f $newline
        $body += "      <ul>{0}" -f $newline
        ForEach($IP in $adapter.IPAddress) {
            $body += "        <li>{0}</li>{1}" -f $IP, $newline
        }
        $body += "      </ul>{0}" -f $newline
        $body += "      <li><b>MAC:</b> {0}</li>{1}" -f $adapter.MACAddress, $newline
        $body += "    </ul>{0}" -f $newline
    }
}
$body += "  </ul>{0}" -f $newline
$body += "</ul>{0}" -f $newline
$body += "<br><p>Script ran by <b>{0} {1}</b> from <b>{2}<b></p>{3}" -f $user.DS_givenName, $user.DS_sn, $user.DS_department, $newline

Send-MailMessage  -SmtpServer "ltc-apps2.ltc-nt.com" -From $from -To "itstudentemployees@gotoltc.edu" -Cc "wendy.nasgovitz@gotoltc.edu" -Bcc "elliott.saille@gotoltc.edu" -Subject "Machine Information for $($system.Name)" -Body $body -BodyAsHtml

cls #Clear Screen

Write-Centered "Thank you for helping us get our Inventory in order!" "DarkGreen"
Write-Centered "The Computer Services Team" "Gray"