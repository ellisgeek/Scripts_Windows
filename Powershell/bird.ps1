#region About
<#
.SYNOPSIS
	Wrapper Script to ease the installation and status checking of the Prey NODE.js Client
.PARAMETER action
	Action that should be executed, currently one of "install" or "status".
	install: Installs Prey
	status: Executes Prey's status built in status check to ensure that the
		      client is running smothly
.PARAMETER apiKey
	[OPTIONAL] API Key to use when registering Prey during installaion. If no
	key is provided you will have to manually configure your prey login details.
.NOTES
==================================== About ====================================
===============================================================================
	Author: Elliott Saille <me@esaille.me>
	Date: May 07, 2015
=================================== License ===================================
===============================================================================
	This Source Code Form is subject to the terms of the Mozilla Public License,
	v. 2.0. If a copy of the MPL was not distributed with this file, You can
    obtain one at http://mozilla.org/MPL/2.0/.
===============================================================================
#>
#Requires -RunAsAdministrator
#Requires -Version 2.0
#endregion

#region Parameters
param (
    [parameter(
               Mandatory = $true,
               Position = 0,
               HelpMessage = "Action to take ..."
               )]
    [ValidateSet('install', 'status')]
    [string]$action,
    
    [parameter(
               Mandatory = $false,
               HelpMessage = "Prey API Key ..."
               )]
    [ValidateLength(12, 12)]
    [string]$apiKey = "" # If you have a API key you can insert it here to automatically add the device
                         # this script is run on to your prey account.
)
#endregion

#region Configuration
# UNC path to folder where prey installer(s) are located
$preyInstallerBasePath = "\\ltc-cleveland\sys2\INSTALL\Prey"
# Arguments to pass to installer "/S" is used for a silent install
$arguments = "/S"
#endregion

#region Helper Functions
function Unblock-File {
<#
    .SYNOPSIS
        Unblocks files that were downloaded from the Internet.
    .DESCRIPTION
	    The Unblock-File cmdlet lets you open files that were downloaded from the Internet. It unblocks
        Windows PowerShell script files that were downloaded from the Internet so you can run them, even
        when the Windows PowerShell execution policy is RemoteSigned. By default, these files are
        blocked to protect the computer from untrusted files.
        Before using the Unblock-File cmdlet, review the file and its source and verify that it is safe
        to open.

        Internally, the Unblock-File cmdlet removes the Zone.Identifier alternate data stream, which has
        a value of "3" to indicate that it was downloaded from the Internet.
    
        Shadows Powershell 4.0 Commandlet of same name.
    .PARAMETER Path
        Specifies the files to unblock. Wildcard characters are supported.
    .EXAMPLE Unblock a file
        Unblock-File ./Example.exe
    .EXAMPLE Unblock multiple files
        dir C:\Downloads\*PowerShell* | Unblock-File
    .LINK http://andyarismendi.blogspot.com/2012/02/unblocking-files-with-powershell.html
    .NOTES
        ==================================== About ====================================
        ===============================================================================
	        Author:  Andy Arismendi
            Documentation by: Elliott Saille
        ===============================================================================
#>
#Requires -Version 2.0
    [cmdletbinding(DefaultParameterSetName = "ByName",
                   SupportsShouldProcess = $True)]
    param (
        [parameter(Mandatory = $true,
                   ParameterSetName = "ByName",
                   Position = 0)]
        [string]
        $Path,
        [parameter(Mandatory = $true,
                   ParameterSetName = "ByInput",
                   ValueFromPipeline = $true)]
        $InputObject
    )
    begin {
        Add-Type -Namespace Win32 -Name PInvoke -MemberDefinition @"
        // http://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
        [DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DeleteFile(string name);
        public static int Win32DeleteFile(string filePath) {
            bool is_gone = DeleteFile(filePath); return Marshal.GetLastWin32Error();}
 
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern int GetFileAttributes(string lpFileName);
        public static bool Win32FileExists(string filePath) {return GetFileAttributes(filePath) != -1;}
"@
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName'  {
                $input_paths = Resolve-Path -Path $Path | ? { [IO.File]::Exists($_.Path) } | `
                Select -Exp Path
            }
            'ByInput' {
                if ($InputObject -is [System.IO.FileInfo]) {
                    $input_paths = $InputObject.FullName
                }
            }
        }
        $input_paths | % {
            if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                if ($PSCmdlet.ShouldProcess($_)) {
                    $result_code = [Win32.PInvoke]::Win32DeleteFile($_ + ':Zone.Identifier')
                    if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                        Write-Error ("Failed to unblock '{0}' the Win32 return code is '{1}'." -f `
                                     $_, $result_code)
                    }
                }
            }
        }
    }
}
#endregion

# Actions to available to execute (TODO: make into functions???)
switch ($action) {
    # Install Prey
    install {
        Write-Host("Installing Prey...")
        # Get newest installer (assumes windows is good at sorting)
        # TODO: actually check that this is the newest version
        $installer = Get-ChildItem "$preyInstallerBasePath\prey-windows-*-x86.exe" | `
                     Select-Object -First 1
        #Strip NTFS streams to prevent windows prompting us if wa are sure we want to run the file
        Unblock-File $installer
        
        # If we got a API key pass it along to the installer
        if (-not [string]::IsNullOrEmpty($apiKey)) {
            $arguments += " /API_KEY=$apiKey"
        }
        # Run the installer as Administrator
        Start-Process -FilePath $installer -ArgumentList $arguments -Wait -Verb runas
        
        #Add the prey bin directory to %PATH% so that the prey CLI can be accessed easily
        Start-Process -FilePath powershell.exe -ArgumentList `
            {
                [Environment]::SetEnvironmentVariable('Path',
                                                      $env:Path + ";C:\Windows\Prey\current\bin",
                                                      'Machine') } -Verb runas -WindowStyle 'Hidden'
        Start-Process -FilePath powershell.exe -ArgumentList `
            {
                [Environment]::SetEnvironmentVariable('Path',
                                                      $env:Path + ";C:\Windows\Prey\current\bin",
                                                      'User') } -Verb runas -WindowStyle 'Hidden'
        
        # If we didn't get a API Key launch the gui configurator so that we can login to Prey.
        if ([string]::IsNullOrEmpty($apiKey)) {
            Write-Host("No API Key passed, launching interactive configuration...")
            Start-Process -FilePath "C:\Windows\Prey\current\bin\prey.cmd" -ArgumentList "config gui" `
                          -Verb runas -WindowStyle 'Hidden'
        }
    }
    # Run prey status commands to make sure things are going smooth
    status {
        Write-Host("Checking Prey Status...")
        # Run prey status commands and save output in temp dir so that we can access it in this
        # powershell session
        Start-Process powershell.exe -ArgumentList `
            {
                (& "C:\Windows\Prey\current\bin\prey.cmd" status) | Out-File "$env:TEMP\prey-status.txt"
            } -Verb runas -WindowStyle 'Hidden'
        Start-Process powershell.exe -ArgumentList `
            {
                (& "C:\Windows\Prey\current\bin\prey.cmd" config check) | `
                Out-File "$env:TEMP\prey-config-check.txt"
            } -Verb runas -WindowStyle 'Hidden' -Wait
        # Read back files with prey status information
        Get-Content "$env:TEMP\prey-status.txt"
        Get-Content "$env:TEMP\prey-config-check.txt"
        # Remove Temp Files
        Remove-Item "$env:TEMP\prey-status.txt"
        Remove-Item "$env:TEMP\prey-config-check.txt"
    }
    # Default action (In theory this should not be accessable because of parameter validation but
    # things break)
    default {
        Write-Host("Sumthins Funky...")
    }
}