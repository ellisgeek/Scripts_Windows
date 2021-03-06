function Unblock-File {
<#
    .SYNOPSIS
        Unblocks files that were downloaded from the Internet.
    .DESCRIPTION
	    The Unblock-File cmdlet lets you open files that were downloaded from the Internet. It unblocks
        Windows PowerShell script files that were downloaded from the Internet so you can run them, even
        when the Windows PowerShell execution policy is RemoteSigned. By default, these files are
        blocked to protect the computer from untrusted files.
        Before using the Unblock-File cmdlet, review the file and its source and verify that it is safe
        to open.

        Internally, the Unblock-File cmdlet removes the Zone.Identifier alternate data stream, which has
        a value of "3" to indicate that it was downloaded from the Internet.
    
        Shadows Powershell 4.0 Commandlet of same name.
    .PARAMETER Path
        Specifies the files to unblock. Wildcard characters are supported.
    .EXAMPLE Unblock a file
        Unblock-File ./Example.exe
    .EXAMPLE Unblock multiple files
        dir C:\Downloads\*PowerShell* | Unblock-File
    .LINK http://andyarismendi.blogspot.com/2012/02/unblocking-files-with-powershell.html
    .NOTES
        ==================================== About ====================================
        ===============================================================================
	        Author:  Andy Arismendi
            Documentation by: Elliott Saille
        ===============================================================================
#>
#Requires -Version 2.0
    [cmdletbinding(DefaultParameterSetName = "ByName",
                   SupportsShouldProcess = $True)]
    param (
        [parameter(Mandatory = $true,
                   ParameterSetName = "ByName",
                   Position = 0)]
        [string]
        $Path,
        [parameter(Mandatory = $true,
                   ParameterSetName = "ByInput",
                   ValueFromPipeline = $true)]
        $InputObject
    )
    begin {
        Add-Type -Namespace Win32 -Name PInvoke -MemberDefinition @"
        // http://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
        [DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DeleteFile(string name);
        public static int Win32DeleteFile(string filePath) {
            bool is_gone = DeleteFile(filePath); return Marshal.GetLastWin32Error();}
 
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern int GetFileAttributes(string lpFileName);
        public static bool Win32FileExists(string filePath) {return GetFileAttributes(filePath) != -1;}
"@
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName'  {
                $input_paths = Resolve-Path -Path $Path | ? { [IO.File]::Exists($_.Path) } | `
                Select -Exp Path
            }
            'ByInput' {
                if ($InputObject -is [System.IO.FileInfo]) {
                    $input_paths = $InputObject.FullName
                }
            }
        }
        $input_paths | % {
            if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                if ($PSCmdlet.ShouldProcess($_)) {
                    $result_code = [Win32.PInvoke]::Win32DeleteFile($_ + ':Zone.Identifier')
                    if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                        Write-Error ("Failed to unblock '{0}' the Win32 return code is '{1}'." -f `
                                     $_, $result_code)
                    }
                }
            }
        }
    }
}