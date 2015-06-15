function color($bc,$fc){
    $a = (Get-Host).UI.RawUI
    $a.BackgroundColor = $bc
    $a.ForegroundColor = $fc
}

color "DarkGray" "White"

Write-Host("Installing Google Chrome and Mozilla Firefox")


Start-Process "\\ltc-cleveland\Sys2\INSTALL\Chrome for Business\googlechromestandaloneenterprise.msi"

$firefox = "\\ltc-cleveland\Sys2\INSTALL\Firefox ESR\"
$firefox = Get-ChildItem -Path $firefox -Filter "Firefox Setup *esr.exe"
$firefox = "\\ltc-cleveland\Sys2\INSTALL\Firefox ESR\$($firefox[0].Name)"

Start-Process $firefox