Function Ask-ForInput {
    <#
        .SYNOPSIS Prompt the user for input and optionally have them confirm their input
        .PARAMETER prompt
            Prompt to display for user
        .PARAMETER confirm
            Have the user confirm their input
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
    param
    (
    	[parameter(Mandatory = $true)]
        [string]$prompt = "Please enter some Text",
        [switch]$confirm
    )
    While($true){
        $input = Read-Host $prompt
        If ($confirm) {
            Write-Host("You entered: ") -f DarkCyan -NoNewline; Write-Host($input) -f DarkYellow
            $yn = Read-Host "Is this correct? (Yes/[No])"
            If (($yn.ToLower() -eq "y") -or ($yn.ToLower() -eq "yes")) {
                Return $input
                Break
            }
        } Else {
            Return $input
            Break
        }
    }
}
