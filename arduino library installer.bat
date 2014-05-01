@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem | Set this script version
set version=0.07
rem | Set library for download:
set git_usr=skbrii
set git_repo=biWheel
set "temp_path=c:\tmp1020"


rem set "git_repoame=%git_usr%/%git_repo%"
set "lib=%git_repo%-master"
rem set git_repo=biWheel
rem | Path to Arduino libraries folder:
set ardu_lib_fldr="C:\Program Files (x86)\Arduino\libraries"
rem | Set temp folder:
set "temp_path=c:\tmp1020"

set "giturl=https://github.com/"
set "_s2=/archive/"
set "master=master.zip"
set /p "www_path_to_lib=%giturl%%git_usr%/%git_repo%%_s2%%master%"


set "temp_file_path=%temp_path%\%master%"

echo Hello, this is library installer script, version %version%

rem Creating temp folder
md %temp_path%

bitsadmin /create myDownloadJob
bitsadmin /addfile myDownloadJob %www_path_to_lib% %temp_file_path%
bitsadmin /SetNotifyCmdLine myDownloadJob "%SystemRoot%\system32\bitsadmin.exe" "%SystemRoot%\system32\bitsadmin.exe /complete myDownloadJob"
bitsadmin /resume myDownloadJob

rem чистим за собой
sleep 100

unzip %temp_file_path% -d %temp_path%

set "temp_lib=%temp_path%\%lib%"
set "new_temp_lib=%temp_path%\%git_repo%"

rem echo %temp_lib% %git_repo%
ren  %temp_lib% %git_repo%
rem echo %new_temp_lib% %ardu_lib_fldr%
xcopy %new_temp_lib% %ardu_lib_fldr%\%git_repo% /E

rmdir %temp_path%
bitsadmin /reset
rem del %temp_file_path%
endlocal
exit /b