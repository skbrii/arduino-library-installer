@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem | Set this script version
set version=0.05
rem | Set library for download:
set libname=skbrii/biWheel
set lib=biWheel-master
set libn=biWheel
rem | Path to Arduino libraries folder:
set ardu_lib_fldr=C:\Program Files (x86)\Arduino\libraries
rem | Set temp folder:
set "temp_path=c:\tmp1020"

set "_s1=https://github.com/"
set "_s2=/archive/"
set "_s3=master.zip"
set "www_path_to_lib=%_s1%%libname%%_s2%%_s3%"

set "_d2=master.zip"
set "temp_file_path=%temp_path%\%_d2%"

echo Hello, this is library installer script, version %version%

rem Creating temp folder
md %temp_path%

bitsadmin /create myDownloadJob
bitsadmin /addfile myDownloadJob %www_path_to_lib% %temp_file_path%
bitsadmin /SetNotifyCmdLine myDownloadJob "%SystemRoot%\system32\bitsadmin.exe" "%SystemRoot%\system32\bitsadmin.exe /complete myDownloadJob"
bitsadmin /resume myDownloadJob

rem чистим за собой
sleep 500
unzip %temp_file_path% -d %temp_path%
rem del %temp_file_path%
ren %temp_path%\%lib% %temp_path%\%libn%
copy %temp_path%\%libn% %ardu_lib_fldr%
rem rmdir %temp_path%
bitsadmin /reset
endlocal
exit /b