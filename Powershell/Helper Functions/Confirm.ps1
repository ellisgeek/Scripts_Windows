function confirm
<#
    .SYNOPSIS Prompt the user to confirm an action
    .PARAMETER title
        Prompt Title
    .PARAMETER message
        Prompt Message
    .PARAMETER yesHelp
        Message Shown for yes when ? is entered at the prompt
    .PARAMETER yesHelp
        Message Shown for no when ? is entered at the prompt
    .LINK https:/github.com/ellisgeek/Scripts_Windows
    .NOTE
        ==================================== About ====================================
        ===============================================================================
        	Author: Elliott Saille <me@esaille.me>
        	Date: Aug 3, 2015
        =================================== LICENSE ===================================
        ===============================================================================
            This Source Code Form is subject to the terms of the Mozilla Public License,
            v. 2.0. If a copy of the MPL was not distributed with this file, You can
            obtain one at http://mozilla.org/MPL/2.0/.
        ===============================================================================
#>
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