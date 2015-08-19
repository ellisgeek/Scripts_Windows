Function Log-Start {
  <#
    .SYNOPSIS
        Creates log file
    
    .DESCRIPTION
        Creates log file with path and name that is passed. Checks if log file exists, and if it does deletes it and creates a new one.
        Once created, writes initial logging data
    
    .PARAMETER LogPath
        Mandatory. Path of where log is to be created. Example: C:\Windows\Temp
    
    .PARAMETER LogName
        Mandatory. Name of log file to be created. Example: Test_Script.log
      
    .PARAMETER ScriptVersion
        Mandatory. Version of the running script which will be written in the log. Example: 1.5
    
    .NOTES
        Version:        1.0
        Author:         Luca Sturlese
        Creation Date:  10/05/12
        Purpose/Change: Initial function development
    	
        Version:        1.1
        Author:         Luca Sturlese
        Creation Date:  19/05/12
        Purpose/Change: Added debug mode support
    	
    	Version:        1.2
        Author:         Elliott Saille
        Creation Date:  08/18/15
        Purpose/Change:	Added sanity checking for paths and removed need to manually specify path to log file in other functions
    
    .EXAMPLE
        Log-Start -LogPath "C:\Windows\Temp" -LogName "Test_Script.log" -ScriptVersion "1.5"
  #>
    
    # Setup function parameters
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$LogName,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptVersion
    )
    
    begin {
        # Export path to log file for other functions
        $script:LogFilePath = Join-Path $LogPath $LogName
        
        # Create program log directory if it doesn't exist
        If (-not (Test-Path $LogPath)) {
            New-Item $LogPath -ItemType directory
        } Else {
            # Remove log file if it already exists
            If (Test-Path -Path $script:LogFilePath) {
                Remove-Item -Path $script:LogFilePath -Force
            }
        }
    }
    Process {
        # Write log header
        Add-Content -Path $script:LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $script:LogFilePath -Value "Started processing at [$([DateTime]::Now)]."
        Add-Content -Path $script:LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $script:LogFilePath -Value ""
        Add-Content -Path $script:LogFilePath -Value "Running script version [$ScriptVersion]."
        Add-Content -Path $script:LogFilePath -Value ""
        Add-Content -Path $script:LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $script:LogFilePath -Value ""
        
        #Write to screen for debug mode
        Write-Debug "***************************************************************************************************"
        Write-Debug "Started processing at [$([DateTime]::Now)]."
        Write-Debug "***************************************************************************************************"
        Write-Debug ""
        Write-Debug "Running script version [$ScriptVersion]."
        Write-Debug ""
        Write-Debug "***************************************************************************************************"
        Write-Debug ""
    }
}

Function Log-Write {
  <#
    .SYNOPSIS
        Writes to a log file
  
    .PARAMETER LineValue
        Mandatory. The string that you want to write to the log
  
    .PARAMETER LogLevel
        Mandetory. Importance of the log message
      
    .NOTES
        Version:        1.0
        Author:         Luca Sturlese
        Creation Date:  10/05/12
        Purpose/Change: Initial function development
      
        Version:        1.1
        Author:         Luca Sturlese
        Creation Date:  19/05/12
        Purpose/Change: Added debug mode support
    	
    	Version:        1.2
        Author:         Elliott Saille
        Creation Date:  08/18/15
        Purpose/Change:	Added Info and Debug log levels, line timestamps, and automatically getting file to write to
    
    .EXAMPLE
        Log-Write -LineValue "This is a new line which I am appending to the end of the log file." -LogLevel Info
  #>
    
    # Setup Function Parameters
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$LineValue,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Info", "Debug")]
        [string]$LogLevel = "Info"
    )
    
    Process {
        # Write line to log file
        Add-Content -Path $script:LogFilePath -Value "[$([DateTime]::Now)]$($LogLevel): $($LineValue)"
        
        #Write to screen for debug mode
        Write-Debug "[$([DateTime]::Now)]$($LogLevel): $($LineValue)"
    }
}

Function Log-Error {
    <#
    .SYNOPSIS
        Writes an error to a log file

    .PARAMETER ErrorDesc
        Mandatory. The description of the error you want to pass (use $_.Exception)
    
    .PARAMETER ErrorObject
        Mandetory. Object generated by the error (use $_)
  
    .PARAMETER ExitGracefully
        Switch. If set to True, runs Log-Finish and then exits script
    
    .INPUTS
        Parameters above
    
    .OUTPUTS
        None
    
    .NOTES
        Version:        1.0
        Author:         Luca Sturlese
        Creation Date:  10/05/12
        Purpose/Change: Initial function development
        
        Version:        1.1
        Author:         Luca Sturlese
        Creation Date:  19/05/12
        Purpose/Change: Added debug mode support. Added -ExitGracefully parameter functionality
    	
    	Version:        1.2
        Author:         Elliott Saille
        Creation Date:  08/18/15
        Purpose/Change: Added line timestamps, importing entire error for future use, and automatically getting file to
                        write to, changed -ExitGracefully to a Switch
    
    .EXAMPLE
        Log-Error -ErrorDesc $_.Exception -ExitGracefully $True
  #>
    
    #Setup function parameters
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ErrorDesc,
        
        [Parameter(Mandatory = $false)]
        [object]
        $ErrorObject,
        
        [switch]$ExitGracefully
    )
    
    Process {
        #If no error object Just print description
        If ([string]::IsNullOrEmpty($ErrorObject)) {
            # Write line to log file
            Add-Content -Path $Script:LogFilePath -Value "[$([DateTime]::Now)]Error: $ErrorDesc."
            
            #Write to screen for debug mode
            Write-Debug "Error: $ErrorDesc."
        } Else {
            # Write line to log file
            Add-Content -Path $Script:LogFilePath -Value "[$([DateTime]::Now)]Error: $ErrorDesc [$($ErrorObject.Exception)]."
            
            #Write to screen for debug mode
            Write-Debug "Error: $ErrorDesc [$($ErrorObject.Exception)]."
        }
        
        #If $ExitGracefully = True then run Log-Finish and exit script
        If ($ExitGracefully) {
            Log-Finish
            Break
        }
    }
}

Function Log-Finish {
  <#
    .SYNOPSIS
        Write closing logging data & exit
    .DESCRIPTION
        Writes finishing logging data to specified log and then exits the calling script
  
    .PARAMETER Exit
        Optional. If this is set to True, then the function will not exit the calling script, so that further execution can occur
    
    .OUTPUTS
        None
    
    .NOTES
        Version:        1.0
        Author:         Luca Sturlese
        Creation Date:  10/05/12
        Purpose/Change: Initial function development
        
        Version:        1.1
        Author:         Luca Sturlese
        Creation Date:  19/05/12
        Purpose/Change: Added debug mode support
      
        Version:        1.2
        Author:         Luca Sturlese
        Creation Date:  01/08/12
        Purpose/Change: Added option to not exit calling script if required (via optional parameter)
    	
    	Version:		1.3
    	Author:			Elliott Saille
    	Creation Date:	08/18/15
    	Purpose/Change:	Added automatically getting file to write to, changed -NoExit to a switch named -Exit
        
    .EXAMPLE
        Log-Finish
    
    .EXAMPLE
        Log-Finish -Exit
  #>
    
    # Setup function Parameters
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Exit
    )
    
    Process {
        # Write log Footer
        Add-Content -Path $Script:LogFilePath -Value ""
        Add-Content -Path $Script:LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $Script:LogFilePath -Value "Finished processing at [$([DateTime]::Now)]."
        Add-Content -Path $Script:LogFilePath -Value "***************************************************************************************************"
        
        # Write to screen for debug mode
        Write-Debug ""
        Write-Debug "***************************************************************************************************"
        Write-Debug "Finished processing at [$([DateTime]::Now)]."
        Write-Debug "***************************************************************************************************"
        
        # Exit calling script if -Exit parameter is specified
        If ($Exit -or ($Exit -eq $True)) {
            Exit
        }
    }
}
