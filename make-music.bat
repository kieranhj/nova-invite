@echo off
mkdir build
echo Building MUSIC...
bin\SongToYM.exe --psg 1 data\music\Acid_demo_07.aks build\acid_demo.ym
python ..\ym2149f\ym2sn.py --white build/acid_demo.ym -o build/acid_demo.vgm
python ..\vgm-packer\vgmpacker.py build/acid_demo.vgm -o build/acid_demo.vgc
