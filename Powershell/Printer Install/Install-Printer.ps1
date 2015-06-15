#region About
<#
    .SYNOPSIS
        Simplifies the installation of printers and allows for easy integration with SCCM
    .DESCRIPTION
        TODO: Write Description
    .PARAMETER Action
	    Action that should be executed, currently one of "install" or "list".
	    install: Installs the printer specified by the PrinterName Parameter
	    list: List all available printers [DEFAULT ACTION]
    .PARAMETER PrinterName
        Name of the printer to be isntalled as displayed by the list command
    .LINK 
    .NOTE
        ==================================== About ====================================
        ===============================================================================
        	Author: Elliott Saille <me@esaille.me>
        	Date: May 19, 2015
        ================================ LICENSE ================================
        =========================================================================
        This Source Code Form is subject to the terms of the Mozilla Public License,
        v. 2.0. If a copy of the MPL was not distributed with this file, You can
        obtain one at http://mozilla.org/MPL/2.0/.
        =========================================================================
#>
#Requires -Version 2.0
#endregion

#region Parameters
param (
    [parameter(
               Mandatory = $true,
               Position = 0,
               HelpMessage = "Action to take ..."
               )]
    [ValidateSet('list', 'install')]
    [string]$Action,
    [parameter(Position = 1)]
    [string]$PrinterName
)
<#DynamicParam {
    if ($Action -eq "install") {
        $PrinterNameAttribute = New-Object System.Management.Automation.ParameterAttribute
        $PrinterNameAttribute.Position = 1
        $PrinterNameAttribute.Mandatory = $true
        $PrinterNameAttribute.HelpMessage = "Please enter the name of the printer to install 
                                    (as shown by the list command):"
        $validateAttribute = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($PrinterNameAttribute)
        $attributeCollection.Add($validateAttribute)
        $PrinterNameParameter = New-Object System.Management.Automation.RuntimeDefinedParameter(
            'PrinterName', [string], $attributeCollection
        )
        $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('PrinterName', $PrinterNameParameter)
        return $paramDictionary
    }
}#>
#endregion

#region Elevate
function Elevate {
    <#
        .SYNOPSIS
            Automatically (re)launch Powershell script as Administrator including parameters
        .PARAMETER ScriptPath
            Path to the script that should be launched. Defaults to the current script
        .PARAMETER Parameters
            A Hashtable of parameters that should be passed to the elevated script, where the "key" is the
            parameter name and the "value" is the parameter value
        .PARAMETER Exit
            End the current powershell session after launching the script
        .EXAMPLE
            Relaunch the current script as Administrator passing along any parameters passed to the
            current instance and then end the current session.
            
            Elevate -Parameters $PSBoundParameters -Exit
        .LINK https://gist.github.com/ellisgeek/2a0821ebf9bb983e04dc
        .NOTE
            ==================================== About ====================================
            ===============================================================================
            	Author: Elliott Saille <me@esaille.me>
            	Date: May 19, 2015
            =================================== LICENSE ===================================
            ===============================================================================
                This Source Code Form is subject to the terms of the Mozilla Public License,
                v. 2.0. If a copy of the MPL was not distributed with this file, You can
                obtain one at http://mozilla.org/MPL/2.0/.
            ===============================================================================
    #>
    param
    (
        [parameter(Position = 0)]
        [string]$ScriptPath = $script:MyInvocation.MyCommand.Path,
        [parameter(Position = 1)]
        [hashtable]$Parameters,
        [switch]$Exit
    )
    # This will hold our argument string that gets passed to the new powershell instance.
    $arg = ""
    # Only iterate over the Parameters object if we need to
    if (-not [string]::IsNullOrEmpty($Parameters)) {
        # Iterate over the parameters the parent script got and turn them into a string of arguments
        # to pass to the new session
        Foreach ($key in $Parameters.Keys) {
            $value = $Parameters[$key]
            $arg += "-$key $value"
        }
    }
    # Only run if we aren't running as Administrator
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        # Provide Feedback
        Write-Host("Relaunching script as Administrator!")
        Write-Verbose("Restarting script with Administrator rights")
        # Run script in a new session as Administrator.
        Start-Process -FilePath powershell.exe -ArgumentList @("-File `"$ScriptPath`" $arg") `
                      -Verb runas
        
        If ($Exit) {
            Write-Verbose("Ending current Session")
            # Return non zero exit code that can be used to check if script was relaunched
            $host.SetShouldExit(42)
            # End current session and let the new one take over
            Exit
        }
    }
}
# Elevate this script, passing any arguments to the new session
Elevate -Parameters $PSBoundParameters -Exit
#endregion

#region Program Helper Functions
Import-Module Appx
Import-Module PrintManagement
Import-Module AppLocker
Import-Module \\ltc-cleveland\menu\Powershell\Modules\PSExcel

# The Following 3 Functions were written by Kris Powell and can be found at:
# http://www.adminarsenal.com/admin-arsenal-blog/how-to-add-printers-with-powershell
Function CreatePrinterPort {
    param ($PrinterIP, $PrinterPort, $PrinterPortName, $ComputerName)
    $wmi = [wmiclass]"\\$ComputerName\root\cimv2:win32_tcpipPrinterPort"
    $wmi.psbase.scope.options.enablePrivileges = $true
    $Port = $wmi.createInstance()
    $Port.name = $PrinterPortName
    $Port.hostAddress = $PrinterIP
    $Port.portNumber = $PrinterPort
    $Port.SNMPEnabled = $false
    $Port.Protocol = 1
    $Port.put()
}

Function InstallPrinterDriver {
    Param ($DriverName, $DriverPath, $DriverInf, $ComputerName)
    $wmi = [wmiclass]"\\$ComputerName\Root\cimv2:Win32_PrinterDriver"
    $wmi.psbase.scope.options.enablePrivileges = $true
    $wmi.psbase.Scope.Options.Impersonation = `
    [System.Management.ImpersonationLevel]::Impersonate
    $Driver = $wmi.CreateInstance()
    $Driver.Name = $DriverName
    $Driver.DriverPath = $DriverPath
    $Driver.InfName = $DriverInf
    $wmi.AddPrinterDriver($Driver)
    $wmi.Put()
}

Function CreatePrinter {
    param ($PrinterCaption, $PrinterPortName, $DriverName, $ComputerName)
    $wmi = ([WMIClass]"\\$ComputerName\Root\cimv2:Win32_Printer")
    $Printer = $wmi.CreateInstance()
    $Printer.Caption = $PrinterCaption
    $Printer.DriverName = $DriverName
    $Printer.PortName = $PrinterPortName
    $Printer.DeviceID = $PrinterCaption
    $Printer.Put()
}

# Easy Access to the path of the folder that the script is stored in
$scriptPath = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction 'Stop'
#endregion

#region Config
# Names of the folders for 32 and 64 bit printer drivers. These should be subfolders of $drivers.Path
$driver64folder = "64bit"
$driver32folder = "32bit"
#
$printersFile = Join-Path $scriptPath "Printers.xlsx"
$printersFileTemp = Join-Path $env:TEMP "Printers.xlsx"
#endregion

#region Load
# Copy the printers file to the local disk as Excel is unable to load it from the network
Copy-Item $printersFile $printersFileTemp
# Load Excel sheets
[System.Collections.ArrayList]$global:printers = Import-XLSX -Path:$printersFileTemp `
                                                             -Sheet:1
[System.Collections.ArrayList]$global:drivers = Import-XLSX -Path:$printersFileTemp `
                                                            -Sheet:2
# Remove the Temp File
Remove-Item $printersFileTemp

# Create Printer name property for each printer based on Room, Department, Make, and Model and
# load names into listbox for easy selection
foreach ($printer in $global:printers) {
    # Get index of current item in array
    $index = [array]::IndexOf($global:printers, $printer)
    # Build Printer Name
    If (-not ([string]::IsNullOrEmpty($printer.Note))) {
        $name = [string]::Format(
        "[{0}] {1} - {2} {3} [{4}]",
        $printer.Room,
        $printer.Department,
        $printer.Brand,
        $printer.Model,
        $printer.Note
        )
    }
    Else {
        $name = [string]::Format(
        "[{0}] {1} - {2} {3}",
        $printer.Room,
        $printer.Department,
        $printer.Brand,
        $printer.Model
        )
    }
    # Add Printer Name as new property of the correct object in the array
    Add-Member -InputObject $global:printers[$index] -Type:'NoteProperty' -Name 'Name' -Value $name
    
    #Write some Debug info
    Write-Debug("Loaded Printer: $($printer.Name)")
}
#endregion

switch ($Action) {
    list {
        Write-Host(
        "Available Printers!`nCopy Printer Name and pass to the script with the install action`n"
        )
        $printers | Select-Object Department, Room, Name | Format-Table -AutoSize -Wrap
        pause
    }
    install {
        $printer = $printers[([array]::IndexOf($Printers.Name, $PSBoundParameters.PrinterName))]
        $driver = $global:drivers | Where-Object { $_.'Friendly Name' -eq $printer.Driver }
        
        Write-Host("Installing Printer " + $printer.Name)
        
        if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture = '64-Bit') {
            Write-Debug("Using 64bit Driver")
            $Driver_Path = Join-Path $driver.Path $driver64folder
        }
        Else {
            Write-Debug("Using 32bit Driver")
            $Driver_Path = Join-Path $driver.Path $driver32folder
        }
        If (-Not ([string]::IsNullOrEmpty($driver.'64bit INF'))) {
            Write-Debug("Using 64bit INF")
            $INF = $driver.'64bit INF'
        }
        Else { $INF = $driver.INF }
        
        Write-Debug("Installing Driver `"$($driver.Name)`" from $INF in $Driver_Path")
        InstallPrinterDriver -DriverName $driver.Name `
                             -DriverPath $Driver_Path `
                             -DriverInf "$Driver_Path\$INF" `
                             -ComputerName 'localhost'
        
        Write-Debug("Creating Printer Port `"$($printer.Name)`" with IP $($printer.IP) and PORT 
                    $($printer.Port)")
        CreatePrinterPort -PrinterIP $printer.IP `
                          -PrinterPort $printer.Port `
                          -PrinterPortName $printer.Name `
                          -ComputerName 'localhost'
        
        Write-Debug("Adding Printer `"$($printer.Name)`" with Port `"$($printer.Name)`" and Driver 
                    `"$($Driver.Name)`"")
        CreatePrinter -PrinterCaption $printer.Name `
                      -PrinterPortName $printer.Name `
                      -DriverName $Driver.Name `
                      -ComputerName 'localhost'
        Write-Host("Printer Installed!")
    }
    default {
        Write-Host("Sumthins Funky...")
    }
}
