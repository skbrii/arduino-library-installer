@echo off
rem | Set this script version
	set /p %version = "Version 0.01"
rem | Set library for download:
	set /p %libname = "skbrii/biWheel"
rem | Path to Arduino libraries folder:
	set /p %path_to_ardu_lib_fldr = "C:\Program Files (x86)\Arduino\libraries"

	
set /p %www_path_to_lib = "https://github.com/" + %libname + "/archive/master.zip"

echo ^Hello, this is library installer script, %version^
echo 