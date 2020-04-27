@echo off
mkdir build
echo Building PNGS...
python bin/png2bbc.py --quiet -o build/n.bin ./data/images/N.png 4
python bin/png2bbc.py --quiet -o build/o.bin ./data/images/O.png 4
python bin/png2bbc.py --quiet -o build/v.bin ./data/images/V.png 4
python bin/png2bbc.py --quiet -o build/a.bin ./data/images/A.png 4
python bin/png2bbc.py --quiet -o build/nova.bin ./data/images/nova.png 4
python bin/png2bbc.py --quiet -o build/nova4.bin ./data/images/nova4.png 4
python bin/png2bbc.py --quiet -o build/bs_logo.bin ./data/images/bslogo_square.png -p 03 4 
python bin/png2bbc.py --quiet --fixed-16 -o build/turbulent.bin "./data/anims/palette_shift_01_64x256 (turbulent circle).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/triangle.bin "./data/anims/palette_shift_02_64x256 (triangle rounded).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/claw.bin "./data/anims/palette_shift_03_64x256 (claw and ball).png" 2 

bin\exomizer.exe level -M256 build/n.bin@0x0000 -o build/n.exo
bin\exomizer.exe level -M256 build/o.bin@0x0000 -o build/o.exo
bin\exomizer.exe level -M256 build/v.bin@0x0000 -o build/v.exo
bin\exomizer.exe level -M256 build/a.bin@0x0000 -o build/a.exo
bin\exomizer.exe level -M256 build/nova.bin@0x0000 -o build/nova.exo
bin\exomizer.exe level -M256 build/nova4.bin@0x0000 -o build/nova4.exo
bin\exomizer.exe level -M256 build/bs_logo.bin@0x0000 -o build/bs_logo.exo

bin\exomizer.exe level -M256 data/anims/a.atom@0x0000 -o build/atom.exo
bin\exomizer.exe level -M256 data/anims/a.cross@0x0000 -o build/cross.exo
bin\exomizer.exe level -M256 data/anims/a.galaxy@0x0000 -o build/galaxy.exo
bin\exomizer.exe level -M256 data/anims/a.world@0x0000 -o build/world.exo
bin\exomizer.exe level -M256 data/anims/palette_shift_test.bin@0x0000 -o build/shift.exo

bin\exomizer.exe level -M256 build/turbulent.bin@0x0000 -o build/turbulent.exo
bin\exomizer.exe level -M256 build/triangle.bin@0x0000 -o build/triangle.exo
bin\exomizer.exe level -M256 build/claw.bin@0x0000 -o build/claw.exo

echo Building MUSIC...
rem python ..\vgm-packer\vgmpacker.py "data/intro_test.vgm" -o build/intro_theme.vgc
rem python ..\vgm-packer\vgmpacker.py "data/main_test.vgm" -o build/main_theme.vgc
python ..\vgm-packer\vgmpacker.py "data/music/acid_test.vgm" -o build/acid_test.vgc
