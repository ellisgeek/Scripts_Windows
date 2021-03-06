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
        .LINK https:/github.com/ellisgeek/Scripts_Windows
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