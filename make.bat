@echo off
if "%1" == "" goto args_count_wrong
if "%2" == "" goto args_count_ok

:args_count_wrong
echo "Usage: make <AKS filename>"
exit /b 1

:args_count_ok
mkdir build
echo Building EVENTS...
bin\SongToRaw.exe -c 4 --dontEncodeSongSubsongMetadata --dontEncodeReferenceTables --dontEncodeSpeedTracks --dontEncodeEventTracks --dontEncodeInstruments --dontEncodeArpeggios --dontEncodePitches --dontEncodetranspositionsInLinker --dontEncodeHeightsInLinker -bin -adr 0x400 %1 build\events.bin

if %ERRORLEVEL% neq 0 (
	echo Failed to extract events from AKS file '%1'...
	exit /b 1
)

echo Building INVITE...
bin\beebasm.exe -i nova-invite.asm -v > compile.txt

if %ERRORLEVEL% neq 0 (
	echo Failed to build code!
	exit /b 1
)

echo Building DISC...
mkdir disc
bin\beebasm.exe -i disc-build.asm -do disc\nova-invite.ssd -title NOVA-INVITE -opt 3 -v

if %ERRORLEVEL% neq 0 (
	echo Failed to build disc image 'nova-invite.ssd'
	exit /b 1
)
