REM # ==================================== About ====================================
REM # ===============================================================================
REM #     Author: Elliott Saille <me@esaille.me>
REM #     Date: June 16, 2015
REM # =================================== License ===================================
REM # ===============================================================================
REM #     This Source Code Form is subject to the terms of the Mozilla Public License,
REM #     v. 2.0. If a copy of the MPL was not distributed with this file, You can
REM #     obtain one at http://mozilla.org/MPL/2.0/.
REM # ===============================================================================

@echo off
cls

rem Set Office Version (Office15 for 2013, Office14 for 2010)
  set VER=Office15

rem Keys for Office (Current as of 4/7/15)
set  Office_Key=
set   Visio_Key=
set Project_Key=

rem Check what system we are installing on and set script path to match
  IF EXIST "%PROGRAMFILES(X86)%\Microsoft Office\%VER%\ospp.vbs" (
    SET "LOC=%PROGRAMFILES(X86)%"
    goto Main
  ) 
  IF EXIST "%PROGRAMFILES%\Microsoft Office\%VER%\ospp.vbs" (
    SET "LOC=%PROGRAMFILES%"
    goto Main
  )

:Main
  rem Add Key for Office
    cscript "%LOC%\Microsoft Office\%VER%\ospp.vbs" /inpkey:%Office_Key%

  rem Add Key for Visio
    cscript "%LOC%\Microsoft Office\%VER%\ospp.vbs" /inpkey:%Visio_Key%

  rem Add Key for Project
    cscript "%LOC%\Microsoft Office\%VER%\ospp.vbs" /inpkey:%Project_Key%


  rem Activate Office Products
    cscript "%LOC%\Microsoft Office\%VER%\ospp.vbs" /act

  rem Print activation status
    cscript "%LOC%\Microsoft Office\%VER%\ospp.vbs" /dstatus

  pause