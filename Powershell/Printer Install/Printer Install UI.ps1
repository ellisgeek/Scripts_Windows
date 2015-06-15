#region About
<#
	.SYNOPSIS
	    Simplifies the installation of printers and allows multiple printers to be installed quickly.
	.DESCRIPTION
	    TODO: Write Description
	.LINK 
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
#Requires -Version 2.0
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
	# Only iterate over the params object if we need to
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
	                    -Verb runas -WindowStyle 'Hidden' # Uncomment this line if you are using
	                                                    # .NET Forms to hide the Powershell
	                                                    # window that is spawned by the new
	                                                    # session
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

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-Printer_Install_GUI_-_Excel_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$printerinstall = New-Object 'System.Windows.Forms.Form'
	$printers_list = New-Object 'System.Windows.Forms.CheckedListBox'
	$output = New-Object 'System.Windows.Forms.RichTextBox'
	$buttonCancel = New-Object 'System.Windows.Forms.Button'
	$buttonInstall = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	#region Program Helper Functions
	Import-Module .\PSExcel\PSExcel
	
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
	#endregion
	
	#region Control Helper Functions
	function Load-ListBox {
	<#
		.SYNOPSIS
			This functions helps you load items into a ListBox or CheckedListBox.
	
		.DESCRIPTION
			Use this function to dynamically load items into the ListBox control.
	
		.PARAMETER  ListBox
			The ListBox control you want to add items to.
	
		.PARAMETER  Items
			The object or objects you wish to load into the ListBox's Items collection.
	
		.PARAMETER  DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER  Append
			Adds the item(s) to the ListBox without clearing the Items collection.
		
		.EXAMPLE
			Load-ListBox $ListBox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Load-ListBox $listBox1 "Red" -Append
			Load-ListBox $listBox1 "White" -Append
			Load-ListBox $listBox1 "Blue" -Append
		
		.EXAMPLE
			Load-ListBox $listBox1 (Get-Process) "ProcessName"
	#>
	    Param (
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        [System.Windows.Forms.ListBox]$ListBox,
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        $Items,
	        [Parameter(Mandatory = $false)]
	        [string]$DisplayMember,
	        [switch]$Append
	    )
	    
	    if (-not $Append) {
	        $listBox.Items.Clear()
	    }
	    
	    if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection]) {
	        $listBox.Items.AddRange($Items)
	    }
	    elseif ($Items -is [Array]) {
	        $listBox.BeginUpdate()
	        foreach ($obj in $Items) {
	            $listBox.Items.Add($obj)
	        }
	        $listBox.EndUpdate()
	    }
	    else {
	        $listBox.Items.Add($Items)
	    }
	    
	    $listBox.DisplayMember = $DisplayMember
	}
	
	# Easy access to the .net newline character
	$newline = [Environment]::NewLine
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
	
	$printerinstall_load = {
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
	                "[{1}] {0} - {2} {3} [{4}]",
	                $printer.Room,
	                $printer.Department,
	                $printer.Brand,
	                $printer.Model,
	                $printer.Note
	            )
	        }
	        Else {
	            $name = [string]::Format(
	            "[{1}] {0} - {2} {3}",
	            $printer.Room,
	            $printer.Department,
	            $printer.Brand,
	            $printer.Model
	            )
	        }
	        # Add Printer Name as new property of the correct object in the array
	        Add-Member -InputObject $global:printers[$index] -Type:'NoteProperty' -Name 'Name' -Value $name
	        # Load printers into listbox
	        Load-ListBox $printers_list $printer.Name -Append
	        #Write some Debug info
	        Write-Debug("Loaded Printer: $($printer.Name)")
	    }
	    
	    $output.Text = "Select Printers to install!"
	}
	
	$buttonInstall_Click = {
	    If (-not $printers_list.CheckedItems.Count -gt 0) {
	        $output.Text = "Please select at least one printer from the list on the right!"
	    }
	    Else {
	        $output.Text = ""
	        ForEach ($item in $printers_list.CheckedItems) {
	            $index = [array]::IndexOf($Printers.Name, $item)
	            $printer = $printers[$index]
	            $driver = $global:drivers | Where-Object { $_.'Friendly Name' -eq $printer.Driver }
	            
	            $output.Text += "Installing Printer " + $printer.Name + $newline
	                        
	            if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture = '64-Bit') {
	                Write-Debug("Using 64bit Driver")
	                $Driver_Path = Join-Path $driver.Path $driver64folder
	            } Else {
	                Write-Debug("Using 32bit Driver")
	                $Driver_Path = Join-Path $driver.Path $driver32folder
	            }
	            If (-Not ([string]::IsNullOrEmpty($driver.'64bit INF'))) {
	                Write-Debug("Using 64bit INF")
	                $INF = $driver.'64bit INF'
	            } Else { $INF = $driver.INF }
	            
	            Write-Debug("Installing Driver `"$($driver.Name)`" from $INF in $Driver_Path")
	            InstallPrinterDriver -DriverName $driver.Name `
	                                 -DriverPath $Driver_Path `
	                                 -DriverInf "$Driver_Path\$INF" `
	                                 -ComputerName 'localhost'
	            
	            Write-Debug("Creating Printer Port `"$($printer.Name)`" with IP $($printer.IP) 
            and PORT $($printer.Port)")
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
	            $output.Text += "Printer Installed!" + $newline*2
	        }
	    }
	}
	
	$buttonCancel_Click = {
	    $printerinstall.Close()
	}
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$printerinstall.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonCancel.remove_Click($buttonCancel_Click)
			$buttonInstall.remove_Click($buttonInstall_Click)
			$printerinstall.remove_Load($printerinstall_load)
			$printerinstall.remove_Load($Form_StateCorrection_Load)
			$printerinstall.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$printerinstall.SuspendLayout()
	#
	# printerinstall
	#
	$printerinstall.Controls.Add($printers_list)
	$printerinstall.Controls.Add($output)
	$printerinstall.Controls.Add($buttonCancel)
	$printerinstall.Controls.Add($buttonInstall)
	$printerinstall.ClientSize = '837, 326'
	$printerinstall.Name = "printerinstall"
	$printerinstall.Text = "Install a Printer"
	$printerinstall.add_Load($printerinstall_load)
	#
	# printers_list
	#
	$printers_list.FormattingEnabled = $True
	$printers_list.Location = '12, 12'
	$printers_list.Name = "printers_list"
	$printers_list.Size = '259, 274'
	$printers_list.TabIndex = 5
    $printers_list.CheckOnClick = $True
	#
	# output
	#
	$output.Location = '277, 12'
	$output.Name = "output"
	$output.Size = '548, 274'
	$output.TabIndex = 4
	$output.Text = ""
	#
	# buttonCancel
	#
	$buttonCancel.Location = '93, 292'
	$buttonCancel.Name = "buttonCancel"
	$buttonCancel.Size = '75, 23'
	$buttonCancel.TabIndex = 2
	$buttonCancel.Text = "Cancel"
	$buttonCancel.UseVisualStyleBackColor = $True
	$buttonCancel.add_Click($buttonCancel_Click)
	#
	# buttonInstall
	#
	$buttonInstall.Location = '12, 292'
	$buttonInstall.Name = "buttonInstall"
	$buttonInstall.Size = '75, 23'
	$buttonInstall.TabIndex = 1
	$buttonInstall.Text = "Install"
	$buttonInstall.UseVisualStyleBackColor = $True
	$buttonInstall.add_Click($buttonInstall_Click)
	$printerinstall.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $printerinstall.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$printerinstall.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$printerinstall.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $printerinstall.ShowDialog()

} #End Function

#Call the form
Call-Printer_Install_GUI_-_Excel_psf | Out-Null