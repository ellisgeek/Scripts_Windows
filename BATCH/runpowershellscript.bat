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

@echo off
cls

rem Backup the current computers path
SET PATH_TMP=%PATH%

rem Add color echo folder to the path
SET PATH="%PATH%;\\ltc-cleveland\sys2\INSTALL\_Tech Tools_\cecho"

rem If no file is specified print some usage info
IF "%1"=="" (
  cecho {09}Usage:{0F}
  cecho {02} * {0F}runpowershellscript {0A}<script path>{0F}
  GOTO end
)

rem Set Execution Policy and Run Script
powershell Set-ExecutionPolicy RemoteSigned -Scope Process -Force; Invoke-Expression "%1"

:end
rem Set path back to what it was
SET PATH=%PATH_TMP%

pause