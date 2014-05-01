@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem | Set this script version
set version=0.07
rem | Set library for download:
set git_usr=skbrii
set git_repo=biWheel
rem | TEmp path
set "temp_path=c:\tmp1020"
rem | Path to Arduino libraries folder:
set ardu_lib_fldr="C:\Program Files (x86)\Arduino\libraries"


set "lib=%git_repo%-master"
set "giturl=https://github.com/"
set "master=master.zip"
set /p "www_path_to_lib=%giturl%%git_usr%/%git_repo%/archive/%master%"
set "temp_file_path=%temp_path%\%master%"


echo Hello, this is library installer script, version %version%

rem Creating temp folder
md %temp_path%

rem Magic withs Windows BITSadmin service
bitsadmin /create myDownloadJob
bitsadmin /addfile myDownloadJob %www_path_to_lib% %temp_file_path%
rem bitsadmin /SetNotifyCmdLine myDownloadJob "%SystemRoot%\system32\bitsadmin.exe" "%SystemRoot%\system32\bitsadmin.exe /complete myDownloadJob"
bitsadmin /resume myDownloadJob

sleep 100

rem Разархивируем полученный архив "master.zip", получим папку типа "biWheel-master"
unzip %temp_file_path% -d %temp_path%

set "temp_lib=%temp_path%\%lib%"
set "new_temp_lib=%temp_path%\%git_repo%"

rem Переименовываем папку "biWheel-master" в "biWheel"
ren  %temp_lib% %git_repo%
rem Копируем ее в папку для библиотек Ардуино-ИДЕ
xcopy %new_temp_lib% %ardu_lib_fldr%\%git_repo% /E

rem чистим за собой
rmdir %temp_path%
bitsadmin /reset
rem del %temp_file_path%
endlocal
exit /b