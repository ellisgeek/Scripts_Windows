function Get-ScriptDirectory {
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
    [OutputType([string])]
    if ($hostinvocation -ne $null) {
        Split-Path $hostinvocation.MyCommand.path
    } else {
        Split-Path $script:MyInvocation.MyCommand.Path
    }
}

$ScriptDirectory = Get-ScriptDirectory

. "$ScriptDirectory\Helper Functions\Set-Wallpaper.ps1"
. "$ScriptDirectory\Helper Functions\Lock-Workstation.ps1"

Set-Wallpaper -Path "$ScriptDirectory\Images\Only You.jpg" -Style Center

Lock-WorkStation