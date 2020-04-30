@echo off
mkdir build
echo Building PNGS...
python bin/png2bbc.py --quiet -o build/n.bin ./data/images/N.png 4
python bin/png2bbc.py --quiet -o build/o.bin ./data/images/O.png 4
python bin/png2bbc.py --quiet -o build/v.bin ./data/images/V.png 4
python bin/png2bbc.py --quiet -o build/a.bin ./data/images/A.png 4

python bin/png2bbc.py --quiet -o build/nova.bin ./data/images/ready_nova-logo.png 4
python bin/png2bbc.py --quiet -o build/nova3.bin ./data/images/ready_3novas.png 4
python bin/png2bbc.py --quiet -o build/nova2020.bin ./data/images/ready_novatidy.png 4

python bin/png2bbc.py --quiet -o build/bs_logo.bin ./data/images/bslogo_square.png -p 03 4 
python bin/png2bbc.py --quiet -o build/bs_logo2.bin ./data/images/bitshifters01.png 4 
python bin/png2bbc.py --quiet -o build/tmt_logo.bin ./data/images/ready_tmt02.png 4 
python bin/png2bbc.py --quiet -o build/tmt_logo2.bin ./data/images/ready_torment03.png 4 

python bin/png2bbc.py --quiet --fixed-16 -o build/turbulent.bin "./data/anims/palette_shift_01_64x256 (turbulent circle).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/triangle.bin "./data/anims/palette_shift_02_64x256 (triangle rounded).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/claw.bin "./data/anims/palette_shift_03_64x256 (claw and ball).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/star.bin "./data/anims/palette_shift_04_64x256 (star expand).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/circle.bin "./data/anims/palette_shift_05_64x256 (circle expand).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/faces.bin "./data/anims/palette_shift_06_64x256 (acid faces).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/square.bin "./data/anims/palette_shift_07_64x256 (square dance).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/kaleidoscope.bin "./data/anims/palette_shift_08_64x256 (kaleidoscope).png" 2 

bin\exomizer.exe level -M256 build/n.bin@0x0000 -o build/n.exo
bin\exomizer.exe level -M256 build/o.bin@0x0000 -o build/o.exo
bin\exomizer.exe level -M256 build/v.bin@0x0000 -o build/v.exo
bin\exomizer.exe level -M256 build/a.bin@0x0000 -o build/a.exo
bin\exomizer.exe level -M256 build/nova.bin@0x0000 -o build/nova.exo
bin\exomizer.exe level -M256 build/nova3.bin@0x0000 -o build/nova3.exo
bin\exomizer.exe level -M256 build/nova2020.bin@0x0000 -o build/nova2020.exo
bin\exomizer.exe level -M256 build/bs_logo.bin@0x0000 -o build/bs_logo.exo
bin\exomizer.exe level -M256 build/bs_logo2.bin@0x0000 -o build/bs_logo2.exo
bin\exomizer.exe level -M256 build/tmt_logo.bin@0x0000 -o build/tmt_logo.exo
bin\exomizer.exe level -M256 build/tmt_logo2.bin@0x0000 -o build/tmt_logo2.exo

rem bin\exomizer.exe level -M256 data/anims/a.atom@0x0000 -o build/atom.exo
rem bin\exomizer.exe level -M256 data/anims/a.cross@0x0000 -o build/cross.exo
rem bin\exomizer.exe level -M256 data/anims/a.galaxy@0x0000 -o build/galaxy.exo
bin\exomizer.exe level -M256 data/anims/a.world@0x0000 -o build/world.exo
bin\exomizer.exe level -M256 data/anims/palette_shift_test.bin@0x0000 -o build/shift.exo

bin\exomizer.exe level -M256 build/turbulent.bin@0x0000 -o build/turbulent.exo
bin\exomizer.exe level -M256 build/triangle.bin@0x0000 -o build/triangle.exo
bin\exomizer.exe level -M256 build/claw.bin@0x0000 -o build/claw.exo
bin\exomizer.exe level -M256 build/star.bin@0x0000 -o build/star.exo
bin\exomizer.exe level -M256 build/circle.bin@0x0000 -o build/circle.exo
bin\exomizer.exe level -M256 build/faces.bin@0x0000 -o build/faces.exo
bin\exomizer.exe level -M256 build/square.bin@0x0000 -o build/square.exo
bin\exomizer.exe level -M256 build/kaleidoscope.bin@0x0000 -o build/kaleidoscope.exo
