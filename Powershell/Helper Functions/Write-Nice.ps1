Function Write-Nice {
    <#
        .SYNOPSIS
            Provides formatting options when printing text to the terminal.
        .PARAMETER Object
            Objects to display in the console.
        .PARAMETER ForegroundColor
            Specifies the foreground color. There is no default.
        .PARAMETER BackgroundColor
            Specifies the background color. There is no default.
        .PARAMETER Center
            Center text on screen. (Only works in console.)
        .PARAMETER Underline
            Underline the displayed text.
        .PARAMETER UnderlineForegroundColor
            Specifies the foreground color of the Underline.
            Defaults to the foreground color of the underlined text.
        .PARAMETER UnderlineBackgroundColor
            Specifies the background color of the Underline.
            Defaults to the background color of the underlined text.
        .PARAMETER UnderlineCharacter
            Character to use for the underline. Defaults to "=".
        .LINK https:/github.com/ellisgeek/Scripts_Windows
        .NOTE
            ==================================== About ====================================
            ===============================================================================
            	Author: Elliott Saille <me@esaille.me>
            	Date: July 13, 2015
            =================================== LICENSE ===================================
            ===============================================================================
                This Source Code Form is subject to the terms of the Mozilla Public License,
                v. 2.0. If a copy of the MPL was not distributed with this file, You can
                obtain one at http://mozilla.org/MPL/2.0/.
            ===============================================================================
    #>
    Param (
        [Parameter(Position = 0)]
        [string]$Object,
        [ValidateSet(
            "Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray",
            "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow", "Gray",
            "Green", "Magenta", "Red", "White", "Yellow"
        )]
        [Alias("f")]
        [string]$ForegroundColor = [console]::ForegroundColor,
        [ValidateSet(
            "Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray",
            "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow", "Gray",
            "Green", "Magenta", "Red", "White", "Yellow"
        )]
        [Alias("b")]
        [string]$BackgroundColor = [console]::BackgroundColor,
        [ValidateSet(
            "Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray",
            "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow", "Gray",
            "Green", "Magenta", "Red", "White", "Yellow"
        )]
        [Alias("ulf")]
        [string]$UnderlineForegroundColor = $ForegroundColor,
        [ValidateSet(
            "Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray",
            "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow", "Gray",
            "Green", "Magenta", "Red", "White", "Yellow"
        )]
        [Alias("ulb")]
        [string]$UnderlineBackgroundColor = $BackgroundColor,
        [string]$UnderlineCharacter = "=",
        [Alias("ul")]
        [switch]$Underline,
        [Alias("c")]
        [switch]$Center
    )
    
    $Offset = [Math]::Round(([Console]::WindowWidth / 2) + ($Object.Length / 2))
    $Line = $UnderlineCharacter*$Object.Length
    
    If ($Underline -and $Center) {
        Write-Host("{0,$Offset}" -f $Object) -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
        Write-Host("{0,$Offset}" -f $Line) -ForegroundColor $UnderlineForegroundColor -BackgroundColor $UnderlineBackgroundColor
    } ElseIf ($Underline) {
        Write-Host($Object) -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
        Write-Host($Line) -ForegroundColor $UnderlineForegroundColor -BackgroundColor $UnderlineBackgroundColor
    } ElseIf ($Center) {
        Write-Host("{0,$Offset}" -f $Object) -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    } Else {
        Write-Host($Object) -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}