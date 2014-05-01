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
set "www_path_to_lib=%giturl%%git_usr%/%git_repo%/archive/%lib%.zip"
rem https://github.com/skbrii/biWheel/archive/biWheel-master.zip
set "temp_file_path=%temp_path%\%lib%.zip"
set jobName=myDownloadJob


echo Hello, this is library installer script, version %version%

rem Creating temp folder
rem md %temp_path%

rem Magic withs Windows BITSadmin service
bitsadmin /create %jobName%
echo %jobName% %www_path_to_lib% %temp_file_path%
bitsadmin /addfile %jobName% %www_path_to_lib% %temp_file_path%
rem bitsadmin /SetNotifyCmdLine jobName "%SystemRoot%\system32\bitsadmin.exe" "%SystemRoot%\system32\bitsadmin.exe /complete %jobName%"
bitsadmin /resume %jobName%

:check
REM bitsadmin /Info %jobName% > %var1%
for /F "tokens=*" %%i in ('bitsadmin /Info %jobName%') do set var1=%%i
echo -------
echo %var1%
set "var3='%jobName%' TRANSFERRED 1 / 1"
set var2=%var1:%var3%=%%
sleep 2
echo ----
if NOT "%var1%" == "%var2%" (goto :check) else (bitsadmin /resume %jobName%) 
echo ++++
rem sleep 100

rem Разархивируем полученный архив "biWheel-master.zip", получим папку типа "biWheel-master"
unzip %temp_file_path% -d %temp_path%

set "temp_lib=%temp_path%\%lib%"
set "new_temp_lib=%temp_path%\%git_repo%"

rem Переименовываем папку "biWheel-master" в "biWheel"
ren  %temp_lib% %git_repo%
rem Копируем ее в папку для библиотек Ардуино-ИДЕ
xcopy %new_temp_lib% %ardu_lib_fldr%\%git_repo% /E

rem чистим за собой
rem rmdir %temp_path%
bitsadmin /reset
rem del %temp_file_path%
endlocal
exit /b