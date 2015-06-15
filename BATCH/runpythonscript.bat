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

SET     PP_Share=\\ltc-cleveland\sys2\INSTALL
SET     PP_Drive=Y:
SET      PP_Path=%PP_Drive%\_Tech Tools_\Python27
SET       PP_exe=%PP_Path%\python.exe

SET Script_Share=\\ltc-cleveland\MENU\Python
SET Script_Drive=Z:



rem If no file is specified print some usage info
IF "%1"=="" (
  echo "Usage:"
  echo "runpythonscript <script name>"
  echo "Script Resides in %Script_Share%"
  GOTO end
)


rem Share containing a copy of portable python
NET USE %PP_Drive% "%PP_Share%" > nul

rem Share containing your python scripts
NET USE %Script_Drive% "%Script_Share%" > nul

rem Backup the current computers path
SET PATH_TMP=%PATH%

rem Add portable python folder to the path
SET PATH="%PATH%;%PP_Path%"

rem Drop from current folder to folder containing portable python
PUSHD "%PP_Path%"

rem Execute script
"%PP_exe%" "%Script_Drive%\%1"

rem Jump back to previous directory
POPD

rem Set path back to what it was
SET PATH=%PATH_TMP%

rem Unmount Shares
NET USE %PP_Drive% /DELETE /Y > nul
NET USE %Script_Drive% /DELETE /Y > nul

:end
pause