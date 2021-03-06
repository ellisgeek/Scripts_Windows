Function Write-Centered {
    Param(  [string] $message,
            [string] $color = "black")
    $offsetvalue = [Math]::Round(([Console]::WindowWidth / 2) + ($message.Length / 2))
    Write-Host ("{0,$offsetvalue}" -f $message) -ForegroundColor $color
}

$PrintServer = "print-server"
$Port = 9100

$Printers = Get-WmiObject -Class win32_Printer -ComputerName $PrintServer | Sort-Object Name

[System.Collections.ArrayList]$Skipped = @()

foreach ($Printer in $Printers) {
    $Skip = $false
    $SkipReason = ""

    Write-Host "Migrating $($Printer.Name)"
    If ($Printer.PortName -iLike 'IP_*') {
        $IP = $Printer.PortName.TrimStart("IP_")
        Write-Host "*   IP: $($IP)"
        Write-Host "* Port: $($Port)"
    } Else {
        $Skip = $true
        $SkipReason = "Not a IP Printer"
        Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
    }
    
    if ($Printer.DriverName -Like '*HP*') {
        Write-Host "* Make: HP"
        $Driver = "HP Universal Printing PCL 6"
    }
    elseIf ($Printer.DriverName -Like '*Brother*') {
        Write-Host "* Make: Brother"
        $Driver = "Brother Mono Universal Printer (PCL)"
    }
    elseIf ($Printer.DriverName -Like '*Ricoh*') {
        Write-Host "* Make: Ricoh"
        $Driver = "PCL6 Driver for Universal Print"
    }
    else {
        Write-Host "* Make: Unknown"
        $Skip = $true
        $SkipReason = "Not a Model we can Handle"
        Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
    }
    
    If (-not (Test-Connection -Count 2 -Quiet -ComputerName $IP)) {
        $Skip = $true
        $SkipReason = "Printer Offline"
        Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
    }

    If (-not $Skip) {
        Write-Host "* Creating Printer Port: $($Printer.PortName)"
        Try {
            Add-PrinterPort -PrinterHostAddress $IP -PortNumber $Port -Name $Printer.PortName
        } Catch {
            $Skip = $true
            $SkipReason = "Unable to create Printer Port"
            Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
        }
        
        Write-Host "* Installing Printer: $($Printer.Name)"
        Try {
            Add-Printer -Name $Printer.Name -DriverName $Driver -PortName $Printer.PortName -Location $Printer.Location
        } Catch {
            $Skip = $true
            $SkipReason = "Unable to install Printer"
            Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
        }

        Write-Host "* Sharing and Publishing printer: $($Printer.ShareName)"
        Try {
            Set-Printer -Name $Printer.Name -ShareName $Printer.ShareName -Shared $true -Published $true
        } Catch {
            $Skip = $true
            $SkipReason = "Unable to share Printer"
            Write-Host("* Skipping $($Printer.Name) because `"$SkipReason`"")
        }
    }
    
    If ($Skip) {
        Add-Member -InputObject $Printer -Type:'NoteProperty' -Name 'Skip Reason' -Value $SkipReason
        $Skipped.Add($Printer)
    }
    


    Write-Host("")
}

$Skipped | Select-Object "Name", "ShareName", "PortName", "Skip Reason" | Sort-Object "Name" | Format-Table