param (
    [parameter(Mandatory = $true, Position = 1)]
    [string]$Target,
    [parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
    [string]$Path,
    [string]$Description,
    [ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
    [string]$Icon = "\\ltc-cleveland\MENU\Powershell\Icons\Generic Icon.ico,0"
)

#region Helper Functions
function confirm
{
	param (
		[string]$Title = "Continue",
		[string]$Message = "Do you want to continue?",
		[string]$YesHelp = "Continues",
		[string]$NoHelp = "Does not Continue"
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

if (Test-Path $Path) {
    if ((confirm -Title "Shortcut Exists!" `
            -Message "The shortcut at `"$Path`" exists. Overwrite?" `
            -YesHelp "Overwrite existing shortcut" `
            -NoHelp "Do not overwrite existing shortcut") -or ($Y)
    ) {
        Remove-Item $Path
    } Else {
        Break
    }
}

$Shell = New-Object -comObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($Path)
$Shortcut.TargetPath = $Target
If(-not [string]::IsNullOrEmpty($Description)) {$Shortcut.Description = $Description}
$Shortcut.IconLocation = $Icon
$Shortcut.Save()