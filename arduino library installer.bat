@echo off
SETLOCAL ENABLEDELAYEDEXPANSION enableextensions

rem | Set this script version
set version=1.0

echo Hello, this is library installer script, version %version%

rem | Path to Arduino libraries folder:
	set "ardu_lib_fldr=C:\Program Files (x86)\Arduino\libraries"
rem	set "ardu_lib_fldr=C:\Program Files\Arduino\libraries"
rem | Set library for download:
set git_usr=skbrii
set git_repo=BiWheel
rem Or uncomment this 2 lines:
rem set /p git_usr=
rem set /p git_repo=
echo ---------
echo Library %git_usr%/%git_repo% will be installed
echo To install another library follow instruction in sourcecode of this script
echo ---------

rem | TEmp path, must be on the same disk as Arduino folder
set "temp_path=c:\tmp1020"

set "lib=%git_repo%-master"
set "giturl=https://codeload.github.com/"
set "www_path_to_lib=%giturl%%git_usr%/%git_repo%/zip/master"
rem https://codeload.github.com/skbrii/BiWheel/zip/master
set "temp_file_path=%temp_path%\%lib%.zip"
set jobName=myDownloadJob

rem Creating temp folder
md %temp_path%

rem Magic withs Windows BITSadmin service
bitsadmin /create %jobName%
echo %jobName% %www_path_to_lib% %temp_file_path%
bitsadmin /addfile %jobName% %www_path_to_lib% %temp_file_path%
bitsadmin /resume %jobName%

:check
for /F "tokens=*" %%i in ('bitsadmin /Info %jobName%') do set var1=%%i
set "var3='myDownloadJob' TRANSFERRED 1 / 1"
rem Говнокодищще строкой ниже!
set var2=%var1:~39,33%
echo %var2%
call :sleep 2

if "%var2%" == "%var3%" (goto :ch) else (goto :check)
:ch
echo Library downloaded sucessfull!
bitsadmin /complete %jobName%

rem Разархивируем полученный архив "BiWheel-master.zip", получим папку типа "BiWheel-master"
rem unzip %temp_file_path% -d %temp_path%
rem call 7za.exe x %lib%.zip -o%temp_path%
set "dd=^ x^ %temp_file_path%^ -o%temp_path%"
call 7za.exe%dd%

set "temp_lib=%temp_path%\%lib%"
set "new_temp_lib=%temp_path%\%git_repo%"

rem Переименовываем папку "BiWheel-master" в "biWheel"
ren  %temp_lib% %git_repo%
echo Renamed %temp_lib% --^> %git_repo%
rem Копируем ее в папку для библиотек Ардуино-ИДЕ
xcopy "%new_temp_lib%" "%ardu_lib_fldr%\%git_repo%\" /E /I
echo Copied %new_temp_lib% --^> %ardu_lib_fldr%\%git_repo%

rem чистим за собой
rmdir %temp_path% /S /Q
echo garbage cleaned!

echo +
echo +
echo ====================================================
echo Library %git_usr%/%git_repo% installed sucessfull!
echo	( or not? 0_o )
echo		please check!
echo +
echo The end!

:sleep
ping 127.0.0.1 -n 2 -w 1000 > NUL
ping 127.0.0.1 -n %1 -w 1000 > NUL
exit /b

endlocal
pause