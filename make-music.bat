@echo off
mkdir build
echo Building MUSIC...
bin\SongToYM.exe --psg 1 data\music\event_test.aks build\event_test.ym
python ..\ym2149f\ym2sn.py --bass --white build/event_test.ym -o build/bass_test.vgm
python ..\vgm-packer\vgmpacker.py build/bass_test.vgm -o build/bass_test.vgc
