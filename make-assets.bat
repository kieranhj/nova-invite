@echo off
mkdir build
echo Building PNGS...
python bin/png2bbc.py --quiet -o build/n.bin ./data/N.png 4
python bin/png2bbc.py --quiet -o build/o.bin ./data/O.png 4
python bin/png2bbc.py --quiet -o build/v.bin ./data/V.png 4
python bin/png2bbc.py --quiet -o build/a.bin ./data/A.png 4
python bin/png2bbc.py --quiet -o build/nova.bin ./data/nova.png 4
python bin/png2bbc.py --quiet -o build/nova4.bin ./data/nova4.png 4
python bin/png2bbc.py --quiet -o build/bs_logo.bin ./data/bslogo_square.png -p 03 4 

bin\exomizer.exe level -M256 build/n.bin@0x0000 -o build/n.exo
bin\exomizer.exe level -M256 build/o.bin@0x0000 -o build/o.exo
bin\exomizer.exe level -M256 build/v.bin@0x0000 -o build/v.exo
bin\exomizer.exe level -M256 build/a.bin@0x0000 -o build/a.exo
bin\exomizer.exe level -M256 build/nova.bin@0x0000 -o build/nova.exo
bin\exomizer.exe level -M256 build/nova4.bin@0x0000 -o build/nova4.exo
bin\exomizer.exe level -M256 build/bs_logo.bin@0x0000 -o build/bs_logo.exo

bin\exomizer.exe level -M256 data/a.atom@0x0000 -o build/atom.exo
bin\exomizer.exe level -M256 data/a.cross@0x0000 -o build/cross.exo
bin\exomizer.exe level -M256 data/a.galaxy@0x0000 -o build/galaxy.exo
bin\exomizer.exe level -M256 data/a.world@0x0000 -o build/world.exo
bin\exomizer.exe level -M256 data/palette_shift_test.bin@0x0000 -o build/shift.exo

echo Building MUSIC...
rem python ..\vgm-packer\vgmpacker.py "data/intro_test.vgm" -o build/intro_theme.vgc
rem python ..\vgm-packer\vgmpacker.py "data/main_test.vgm" -o build/main_theme.vgc
python ..\vgm-packer\vgmpacker.py "data/acid_test.vgm" -o build/acid_test.vgc
