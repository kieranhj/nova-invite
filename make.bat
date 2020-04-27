@echo off
mkdir build
echo Building EVENTS...
rem bin\SongToEvents -bin -adr 0x0400 data\music\event_test.aks build\events.bin
bin\SongToRaw.exe -c 4 --dontEncodeSongSubsongMetadata --dontEncodeReferenceTables --dontEncodeSpeedTracks --dontEncodeEventTracks --dontEncodeInstruments --dontEncodeArpeggios --dontEncodePitches --dontEncodetranspositionsInLinker --dontEncodeHeightsInLinker -bin -adr 0x400 data\music\event_test.aks build\events.bin

echo Building INVITE...
bin\beebasm.exe -i nova-invite.asm -v > compile.txt
echo Building DISC...
mkdir disc
bin\beebasm.exe -i disc-build.asm -do disc\nova-invite.ssd -title NOVA-INVITE -opt 2 -v
