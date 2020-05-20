@echo off
if "%1" == "" goto args_count_wrong
if "%2" == "" goto args_count_ok

:args_count_wrong
echo "Usage: make-rhino <AKS filename>"
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

echo Building EVENTS...
bin\SongToRaw.exe -c 4 --dontEncodeSongSubsongMetadata --dontEncodeReferenceTables --dontEncodeSpeedTracks --dontEncodeEventTracks --dontEncodeInstruments --dontEncodeArpeggios --dontEncodePitches --dontEncodetranspositionsInLinker --dontEncodeHeightsInLinker -bin -adr 0xC300 %1 build\events.bin

if %ERRORLEVEL% neq 0 (
	echo Failed to extract events from AKS file '%1'...
	exit /b 1
)

python bin\aks_channel_parse_as_events.py build\events.bin -o build\events_reduced.bin

if %ERRORLEVEL% neq 0 (
	echo Failed to parse events file 'events.bin'...
	exit /b 1
)

echo Building CODE...
bin\beebasm.exe -i nova-invite.asm -v > compile.txt

if %ERRORLEVEL% neq 0 (
	echo Failed to build code file. Send `compile.txt` to Kieran!
	exit /b 1
)

echo Building DISC...
mkdir disc
bin\beebasm.exe -i disc-build.asm -do disc\nova-invite.ssd -title NOVA-INVITE -opt 3 -v

if %ERRORLEVEL% neq 0 (
	echo Failed to build disc image 'nova-invite.ssd'
	exit /b 1
)
