﻿#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

Import-Module MsDtc
$passwordLength = 8
$logFile = "\\PATH\TO\LOG\FILE.csv"
$AlertEmail = "netadmin@example.com"
$mailServer = "mail.example.com"


function New-SWRandomPassword {
    <#
    .Synopsis
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .DESCRIPTION
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .EXAMPLE
       New-SWRandomPassword
       C&3SX6Kn

       Will generate one password with a length between 8  and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
       7d&5cnaB
       !Bh776T"Fw
       9"C"RxKcY
       %mtM7#9LQ9h

       Will generate four passwords, each with a length of between 8 and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
       the string specified with the parameter FirstChar
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates random passwords
    .LINK
       http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
   
    #>
    [CmdletBinding(DefaultParameterSetName = 'FixedLength', ConfirmImpact = 'None')]
    [OutputType([String])]
    Param (
        # Specifies minimum password length
        [Parameter(Mandatory = $false,
                   ParameterSetName = 'RandomLength')]
        [ValidateScript({ $_ -gt 0 })]
        [Alias('Min')]
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory = $false,
                   ParameterSetName = 'RandomLength')]
        [ValidateScript({
            if ($_ -ge $MinPasswordLength) { $true } else { Throw 'Max value cannot be lesser than min value.' }
        })]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,
        
        # Specifies a fixed password length
        [Parameter(Mandatory = $false,
                   ParameterSetName = 'FixedLength')]
        [ValidateRange(1, 2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789'),
        
        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String]$FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1, 2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed {
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For ($iteration = 1; $iteration -le $Count; $iteration++) {
            $Password = @{ }
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings
            
            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object { [Char[]]$_ }
            
            # Set password length
            if ($PSCmdlet.ParameterSetName -eq 'RandomLength') {
                if ($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                } else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }
            
            # If FirstChar is defined, randomize first char in password from that string.
            if ($PSBoundParameters.ContainsKey('FirstChar')) {
                $Password.Add(0, $FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach ($Group in $CharGroups) {
                if ($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)) {
                        $Index = Get-Seed
                    }
                    $Password.Add($Index, $Group[((Get-Seed) % $Group.Count)])
                }
            }
            
            # Fill out with chars from $AllChars
            for ($i = $Password.Count; $i -lt $PasswordLength; $i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)) {
                    $Index = Get-Seed
                }
                $Password.Add($Index, $AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}
function log-action {
	param (
		[parameter(Mandatory = $true)]
		[object]$User,
		[parameter(Mandatory = $true)]
		[ValidateSet("Unlock","Reset")]
		[string]$Action,
        [switch]$Completed,
		[string]$Password,
		[switch]$changeAtNextLogin,
        [switch]$Locked,
        [switch]$lockCleared
    )
    $date = Get-Date -Format d
    $time = Get-Date -Format t
    
    $changes = New-Object PSObject -Property @{
        Date = $date;
        Time = $time;
        "User Reset" = $user.logonName;
        "User Name" = $user.Name;
        Action = $Action;
        Completed = $Completed;
        "New Password" = $password;
		"Must Reset on Login" = $changeAtNextLogin;
		"Account Locked" = $user.AccountIsLockedOut;
		"Lockout Cleared" = $lockCleared;
		"Performed By" = $env:USERNAME
    }
    Export-Csv $logFile -Append -InputObject $changes -NoTypeInformation
}

function send-mail {
    param (
        [parameter(Mandatory = $true)]
        [object]$User,
        [parameter(Mandatory = $true)]
        [ValidateSet("Unlock", "Reset")]
        [string]$Action,
        [switch]$Completed,
        [string]$Password,
        [switch]$changeAtNextLogin,
        [switch]$Locked,
        [switch]$lockCleared,
        [parameter(Mandatory = $true)]
        [validateSet("User","Network")]
        [string]$template
    )
    $date = Get-Date -Format d
    $time = Get-Date -Format t
    $changeUser = Get-QADUser $env:USERNAME
    $changes = New-Object PSObject -Property @{
        Date = $date;
        Time = $time;
        "User Reset" = $user.logonName;
        "User Name" = $user.Name;
        Completed = $Completed;
        "New Password" = $password;
        "Must Reset on Login" = $changeAtNextLogin;
        "Account Locked" = $user.AccountIsLockedOut;
        "Lockout Cleared" = $lockCleared;
        "Performed By" = $env:USERNAME
    }
    
    switch ($template) {
        User {
            switch ($action) {
                Reset {
                    $subject = "Your passowrd has been reset"
                    $body = @"
<p style="font-size: 12pt">Your password has been reset because you were having trouble signing in.
<br /><br />
Your password was reset to: <span style="font-family:Monospace; font-size:14px">$Password</span><br />
Please change your password the next time you are on campus.
<br /><br />
If you did not request a password change, contact the Hell Desk immediately.
</p>
"@
                }
                Unlock {
                    Write-Warning "User unlock email has not been implemented yet."
                }
            }
            $to = $User.Email
            $from = $changeUser.Email
        }
        Network {
            switch ($action) {
                Reset {
                    $subject = "$($changeUser.Name) reset $($user.logonName)'s Password"
                    $body = @"
$($User.Name)`'s Password was reset to `"$Password`" by $($changeUser.logonName).

For more information open the log at: $logFile
"@
                }
                Unlock {
                    $subject = "$($changeUser.Name) reset $($user.logonName)'s Password"
                    $body = @"
$($User.Name)`'s Password was unlocked by $($changeUser.logonName).

For more information open the log at: $logFile
"@
                }
            }
        $to = $AlertEmail
        $from = $changeUser.Email
        }
    }
    Write-Host("$subject")
    Send-MailMessage -SmtpServer $mailServer -From $from -To $to -Subject $subject -Body $body -BodyAsHtml
}

function unlock-account()
{
	param
	(
		[parameter(Mandatory = $true)]
		[string]
		$username
    )
    Write-Host $username
	Try
	{
		$user = Get-QADUser -Identity $username -IncludedProperties 'lockoutTime'
	}
	Catch
	{
        Write-Error "Unable to retreve user data"
        Call-Error_psf -Type Error -User $user -ErrorObj $_
	}
	If ($true) {
        $lockout = Call-Lockout_Dialog_psf
		If ($script:DoUnlock -eq $true)
		{
			Try
			{
				Unlock-QADUser $user.LogonName
				$unlocked = $true
			}
			Catch
			{
				Write-Error "Unable to unlock users account!"
                $unlocked = $false
                Call-Error_psf -Type Error -User $user -ErrorObj $_
            }
            log-action -user $user -Action Unlock -Completed:$unlocked -lockCleared:$unlocked
		}
	}
	
}

function do-reset() {
    param ([parameter(Mandatory = $true)]
        [string]$username,
        [switch]$userMustChangePasswordAtNextLogin)
    Try {
        $user = Get-QADUser $username -IncludedProperties 'lockoutTime'
    } Catch {
        Write-Error "Unable to retreve user data"
        Call-Error_psf -Type Error -User $user -ErrorObj $_
    }
    $memberOf = Get-QADMemberOf $username
    
    
    if ($memberOf.Name -inotcontains "Students") {
        Call-Error_psf -Type Rights -User $user
        $formStudentPasswordReset.Close()
	} Else {
		unlock-account -username $user.SamAccountName
        $newPassword = New-SWRandomPassword -PasswordLength $passwordLength
        $confirm = (Call-Confirm_psf -User $user)
        If (($confirm -eq [System.Windows.Forms.DialogResult]::OK) -and ($script:Confirmed -eq $true)) {
            $completed = $true
            If (-not $userMustChangePasswordAtNextLogin) {
                Call-Error_psf -Type NoForceChange -User $user
            }
            
            Try {
                Set-QADUser $user.SamAccountName `
                            -UserPassword $newPassword -UserMustChangePassword $true -ErrorAction Stop
            } Catch {
                Write-Error "Unable to reset users password!"
                $completed = $false
                Call-Error_psf -Type Error -User $user -ErrorObj $_
            }
            log-action -User $user -Action Reset -Completed:$completed -Password $newPassword `
                       -lockCleared:$unlocked -changeAtNextLogin:$userMustChangePasswordAtNextLogin
            
            send-mail -User $user -Action Reset -Completed:$completed -Password $newPassword `
                      -lockCleared:$unlocked -changeAtNextLogin:$userMustChangePasswordAtNextLogin -template User
            
            send-mail -User $user -Action Reset -Completed:$completed -Password $newPassword `
                      -lockCleared:$unlocked -changeAtNextLogin:$userMustChangePasswordAtNextLogin -template Network
            
            Call-New_Password_psf -User $user -Password $newPassword
        }
    }
}