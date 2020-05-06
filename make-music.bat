@echo off
mkdir build
echo Building MUSIC...
bin\SongToYM.exe --psg 1 data\music\Acid_demo_08.aks build\acid_demo.ym
python bin\ym2sn.py --white build/acid_demo.ym -o build/acid_demo.vgm
python bin\vgmpacker.py build/acid_demo.vgm -o build/acid_demo.vgc
