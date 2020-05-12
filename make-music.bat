@echo off
if "%1" == "" goto args_count_wrong
if "%2" == "" goto args_count_ok

:args_count_wrong
echo "Usage: make-music <AKS filename>"
exit /b 1

:args_count_ok
mkdir build
echo Building MUSIC...
bin\SongToYM.exe --psg 1 %1 build\acid_demo.ym

if %ERRORLEVEL% neq 0 (
	echo Failed to export YM data from AKS file '%1'...
	exit /b 1
)

python bin\ym2sn.py --white build/acid_demo.ym -o build/acid_demo.vgm

if %ERRORLEVEL% neq 0 (
	echo Failed to convert YM data to VGM!
	exit /b 1
)

python bin\vgmpacker.py build/acid_demo.vgm -o build/acid_demo.vgc

if %ERRORLEVEL% neq 0 (
	echo Failed to pack VGM file!
	exit /b 1
)
