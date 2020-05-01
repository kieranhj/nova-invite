@echo off
mkdir build
echo Building MUSIC...
bin\SongToYM.exe --psg 1 data\music\Acid_demo_07.aks build\acid_demo.ym
python ..\ym2149f\ym2sn.py --bass --white build/acid_demo.ym -o build/acid_demo_bass_white.vgm
python ..\vgm-packer\vgmpacker.py build/acid_demo_bass_white.vgm -o build/acid_demo_bass_white.vgc
python ..\ym2149f\ym2sn.py --bass build/acid_demo.ym -o build/acid_demo_bass.vgm
python ..\vgm-packer\vgmpacker.py build/acid_demo_bass.vgm -o build/acid_demo_bass.vgc
