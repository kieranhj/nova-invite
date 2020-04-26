@echo off
mkdir build
echo Building EVENTS...
bin\SongToEvents -bin -adr 0x4000 data\event_test.aks build\events.bin
echo Building INVITE...
bin\beebasm.exe -i nova-invite.asm -v > compile.txt
echo Building DISC...
mkdir disc
bin\beebasm.exe -i disc-build.asm -do disc\nova-invite.ssd -title NOVA-INVITE -opt 2 -v

