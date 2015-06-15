#region About
<#
    .SYNOPSIS
        Copy a specified profile to the Windows default profile.
    .PARAMETER Profile
        The name of the profile that should be copied
    .PARAMETER NoBackup
        Do not create a timestamped copy of the old default profile
	.PARAMETER NoLogging
		Disable saving logfile
	.PARAMETER LogFile
		File to save log to
		Defaults to: "C:\Users\Copy Profile.log"
	.PARAMETER Y
		Bypass confirmation prompt and continue
    .EXAMPLE Copy the user "example" to the default profile and backup the old default profile.
		Set-DefProf -Profile example
	.EXAMPLE Copy the user "example" to the default profile and DO NOT backup the old default profile.
		Set-DefProf -Profile example -NoBackup
    .LINK https://gist.github.com/ellisgeek/
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
#endregion
[CmdletBinding(SupportsShouldProcess = $true)]
param
(
	[parameter(
		Mandatory = $true,
		Position = 0,
		ValueFromPipeline = $true
	)]
	[ValidateScript({ Test-Path (Join-Path "C:\Users" $_) })]
	[string]$Profile = "srika",
	[switch]$NoBackup,
	[switch]$NoLogging,
	[ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
	[string]$LogFile = "C:\Users\Set-DefProf_$Profile.log",
	[switch]$Y
)

#region Elevate
function Elevate
{
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
	if (-not [string]::IsNullOrEmpty($Parameters))
	{
		# Iterate over the parameters the parent script got and turn them into a string of arguments
		# to pass to the new session
		Foreach ($key in $Parameters.Keys)
		{
			$value = $Parameters[$key]
			$arg += "-$key $value"
		}
	}
	# Only run if we aren't running as Administrator
	If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		# Provide Feedback
		Write-Host("Relaunching script as Administrator!")
		Write-Verbose("Restarting script with Administrator rights")
		# Run script in a new session as Administrator.
		Start-Process -FilePath powershell.exe -ArgumentList @("-File `"$ScriptPath`" $arg") `
					  -Verb runas
		
		If ($Exit)
		{
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

#region Helper Functions
function confirm
{
	param (
		[string]$title = "Continue",
		[string]$message = "Do you want to continue?",
		[string]$yesHelp = "Continues",
		[string]$noHelp = "Does not Continue"
	)
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", $yesHelp
	
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", $noHelp
	
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	
	$result = $host.ui.PromptForChoice($title, $message, $options, 0)
	
	switch ($result)
	{
		0 { return $true }
		1 { return $false }
	}
}
#endregion

#region Config
$dest = "C:\Users\Default"
$excludeFiles = @("/XF", "*.log", "*.LOG", "*_log")
$excludeDirs = @("/XD", "Temp", "CrashReport*", "imagestore")
$options = @("/S", "/ZB", "/R:2", "/W:1", "/MT", "/XJ", "/NFL", "/NJH", "/ETA")
#endregion

$time = Get-Date -Format yyyy-MM-dd-HH.mm.ss

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	Write-Warning("You do not have Administrator rights to run this script!`n" +
				  "         Please re-run this script as an Administrator!")
	Break
}

if (($Y = $true) -or (confirm -title "WARNING!" `
		-message "If you continue the default profile on this computer will be updated.`n`n" + `
				  "Do you Wish to continue?`n" -yesHelp "Copies srika to default profile." `
		-noHelp "Exit's the program without updating anything."
	)
)
{
	Try
	{
		Move-Item -Path $dest -Destination ([string]::Format("{0}-{1}", $dest, $time)) -ErrorAction 'Stop'
	}
	Catch
	{
		Write-Warning("Unable to rename folder")
		Break
	}
	$cmdArgs = @("$source", "$dest", $options, $excludeFiles, $excludeDirs)
	robocopy @cmdArgs
}