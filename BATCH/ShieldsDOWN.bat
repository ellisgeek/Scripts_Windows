REM # ==================================== About ====================================
REM # ===============================================================================
REM #     Author: Elliott Saille <me@esaille.me>
REM #     Date: June 15, 2015
REM # =================================== License ===================================
REM # ===============================================================================
REM #     This Source Code Form is subject to the terms of the Mozilla Public License,
REM #     v. 2.0. If a copy of the MPL was not distributed with this file, You can
REM #     obtain one at http://mozilla.org/MPL/2.0/.
REM # ===============================================================================

@ECHO OFF
@MODE CON: COLS=28 LINES=1
@TITLE Shields UP!
@COLOR 6F

:PASS
set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set PASS=%%p
ECHO.
IF [%PASS%]==[] (GOTO PASS)

"C:\Program Files\Centurion Technologies\Client\ctsrcmd.exe" disable -p %PASS% > NUL

@MODE CON: COLS=60 LINES=3
@COLOR 28

ECHO  SHIELDS DENERGIZED! REDIRECTING POWER TO CRITICAL SYSTEMS!

TIMEOUT 5 /NOBREAK

SHUTDOWN /R /F /T 0