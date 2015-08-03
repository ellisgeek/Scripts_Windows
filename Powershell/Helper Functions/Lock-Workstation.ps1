Function Lock-WorkStation {
    <#
        .SYNOPSIS Locks the Screen
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
    #Requires -Version 2.0
    $signature = @"
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool LockWorkStation();
"@
    $LockWorkStation = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru
    $LockWorkStation::LockWorkStation() | Out-Null
}