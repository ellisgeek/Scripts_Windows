#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-Shared_Printer_Install_GUI_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	#[void][reflection.assembly]::Load('mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#[void][reflection.assembly]::Load('System.Xml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System.DirectoryServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#[void][reflection.assembly]::Load('System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#[void][reflection.assembly]::Load('System.ServiceProcess, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
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
	#region About
	<#
	    .SYNOPSIS
	        Simplifies the installation of shared printers and allows multiple printers to be installed quickly.
	    .DESCRIPTION
	        TODO: Write Description
	    .LINK 
	    .NOTE
	        ==================================== About ====================================
	        ===============================================================================
	        	Author: Elliott Saille <me@esaille.me>
	        	Date: May 28, 2015
	        =================================== LICENSE ===================================
	        ===============================================================================
	            This Source Code Form is subject to the terms of the Mozilla Public License,
	            v. 2.0. If a copy of the MPL was not distributed with this file, You can
	            obtain one at http://mozilla.org/MPL/2.0/.
	        ===============================================================================
	#>
	#Requires -Version 2.0
	#endregion
	
	#region Program Helper Functions
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
	$PrintServer = "PRINT SERVER" # Server with shared printers!
	#endregion
	
	$printerinstall_load = {
		# Get all shared printers from $PrintServer
		$global:sharedPrinters = Get-WmiObject -Class win32_Printer -ComputerName $PrintServer | Sort-Object Name
	   	
	    # Load names of shared printers into listbox for easy selection
	    foreach ($printer in $global:sharedPrinters) {
	        # Load printers into listbox
	        Load-ListBox $printers_list $printer.Name -Append
	        #Write some Debug info
			Write-Debug([string]::Format("Loaded Shared Printer `"{0}`" from `"\\{1}`"",
									     $printer.Name,
									     $printer.SystemName
			))
	    }
		
		# Create COM Object containing method to add printers
		$global:Network = New-Object -ComObject WScript.Network
		
	    $output.Text = "Select Shared Printers to install!"
	}
	
	$buttonInstall_Click = {
	    If (-not $printers_list.CheckedItems.Count -gt 0) {
	        $output.Text = "Please select at least one printer from the list on the right!"
	    }
	    Else {
	        $output.Text = ""
	        ForEach ($item in $printers_list.CheckedItems) {
				$index = [array]::IndexOf($global:sharedPrinters.Name, $item)
				Write-Host($item)
	            $printer = $sharedPrinters[$index]
	            $path = (Join-Path (Join-Path "\\" $printer.SystemName) $printer.ShareName)
	            $output.Text += "Installing Shared Printer " + $printer.Name + $newline
				
				Write-Debug([string]::Format("Adding Shared Printer `"{0}`" from `"{1}`"",$printer.Name, $path))
				$global:Network.AddWindowsPrinterConnection($path)
				
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
	$printerinstall.ClientSize = '550, 326'
	$printerinstall.FormBorderStyle = 'FixedDialog'
	$printerinstall.MaximizeBox = $False
	$printerinstall.Name = "printerinstall"
	$printerinstall.Text = "Install a Printer"
	$printerinstall.add_Load($printerinstall_load)
	#
	# printers_list
	#
	$printers_list.CheckOnClick = $True
	$printers_list.FormattingEnabled = $True
	$printers_list.Location = '12, 12'
	$printers_list.Name = "printers_list"
	$printers_list.Size = '259, 274'
	$printers_list.TabIndex = 5
	#
	# output
	#
	$output.Location = '277, 12'
	$output.Name = "output"
	$output.Size = '259, 274'
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
Call-Shared_Printer_Install_GUI_psf | Out-Null