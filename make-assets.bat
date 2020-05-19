@echo off
mkdir build
echo Building PNGS...
python bin/png2bbc.py --quiet -o build/image_n.bin ./data/images/N_01.png 4
python bin/png2bbc.py --quiet -o build/image_o.bin ./data/images/O_01.png 4
python bin/png2bbc.py --quiet -o build/image_v.bin ./data/images/V_01.png 4
python bin/png2bbc.py --quiet -o build/image_a.bin ./data/images/A_01.png 4
python bin/png2bbc.py --quiet -o build/image_nova.bin ./data/images/nova-logo_v02.png 4
python bin/png2bbc.py --quiet -o build/image_nova3.bin ./data/images/ready_3novas_v02.png 4
python bin/png2bbc.py --quiet -o build/image_nova2020.bin ./data/images/ready_novatidy.png 4

rem python bin/png2bbc.py --quiet -o build/image_bs_logo.bin ./data/images/bslogo_square.png -p 03 4 
python bin/png2bbc.py --quiet -o build/image_bs_logo2.bin ./data/detexted/bitshifters01_notext.png 4 
python bin/png2bbc.py --quiet -o build/image_tmt_logo.bin ./data/images/ready_tmt02.png 4 
rem python bin/png2bbc.py --quiet -o build/image_tmt_logo2.bin ./data/images/ready_torment03.png 4 
python bin/png2bbc.py --quiet -o build/image_bbc_owl.bin ./data/images/bbc_logo_v03.png 4

python bin/png2bbc.py --quiet -o build/image_wsm_graf.bin ./data/images/wsm_graf_01_v03.png 4 
python bin/png2bbc.py --quiet -o build/image_nova_url.bin ./data/images/Layout_D_v03.png 4 
python bin/png2bbc.py --quiet -o build/image_atari_bee.bin ./data/images/bee_v03.png 4
python bin/png2bbc.py --quiet -o build/image_half_bee.bin ./data/images/hybrid_v03_smoothed.png 4
python bin/png2bbc.py --quiet -o build/image_rocka_1.bin ./data/images/lrocka_v03.png 4
python bin/png2bbc.py --quiet -o build/image_rocka_2.bin ./data/images/lrockb_v04.png 4

rem python bin/png2bbc.py --quiet -o build/slide_dates.bin ./data/images/slide_01_dates_v3.png 4
python bin/png2bbc.py --quiet -o build/slide_beach.bin ./data/detexted/slide_02_beach_v4_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_chips.bin ./data/detexted/slide_03_chipshop_alt_v4_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_floppies.bin ./data/detexted/slide_04_floppytoss_v7_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_djset.bin ./data/detexted/slide_05_djsets_v4_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_firealarm.bin ./data/detexted/slide_06_firealarm_v6_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_kitchen.bin ./data/detexted/slide_07_kitchen_v4_notext.png 4
python bin/png2bbc.py --quiet -o build/slide_patarty.bin ./data/detexted/slide_08_patarty_v3_notext.png 4

python bin/png2bbc.py --quiet --fixed-16 -o build/anim_turbulent.bin "./data/anims/palette_shift_01_64x256 (turbulent circle).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_triangle.bin "./data/anims/palette_shift_02_64x256 (triangle rounded).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_claw.bin "./data/anims/palette_shift_03_64x256 (claw and ball).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_star.bin "./data/anims/palette_shift_04_64x256 (star expand).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_circle.bin "./data/anims/palette_shift_05_64x256 (circle expand).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_faces.bin "./data/anims/palette_shift_06_64x256 (acid faces).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_square.bin "./data/anims/palette_shift_07_64x256 (square dance).png" 2 
python bin/png2bbc.py --quiet --fixed-16 -o build/anim_kaleidoscope.bin "./data/anims/palette_shift_08_64x256 (kaleidoscope).png" 2 

python bin\png2bbcfont.py --transparent-rgb 255 0 0 --transparent-output 0 --glyph-dim 16 16 -o build\font16.bin --quiet --max-glyphs 59 data\fonts\16_x_16_1_col.png 4
python bin\png2bbcfont.py --transparent-rgb 0 255 0 --transparent-output 0 --glyph-dim 24 36 -o build\font24x36_rle.bin --rle --quiet data\fonts\24_x_36_1_col_v06.png 4

bin\exomizer.exe level -M256 -c build/image_n.bin@0x0000 -o build/image_n.exo
bin\exomizer.exe level -M256 -c build/image_o.bin@0x0000 -o build/image_o.exo
bin\exomizer.exe level -M256 -c build/image_v.bin@0x0000 -o build/image_v.exo
bin\exomizer.exe level -M256 -c build/image_a.bin@0x0000 -o build/image_a.exo
bin\exomizer.exe level -M256 -c build/image_nova.bin@0x0000 -o build/image_nova.exo
bin\exomizer.exe level -M256 -c build/image_nova3.bin@0x0000 -o build/image_nova3.exo
bin\exomizer.exe level -M256 -c build/image_nova2020.bin@0x0000 -o build/image_nova2020.exo
rem bin\exomizer.exe level -M256 -c build/image_bs_logo.bin@0x0000 -o build/image_bs_logo.exo
bin\exomizer.exe level -M256 -c build/image_bs_logo2.bin@0x0000 -o build/image_bs_logo2.exo
bin\exomizer.exe level -M256 -c build/image_tmt_logo.bin@0x0000 -o build/image_tmt_logo.exo
bin\exomizer.exe level -M256 -c build/image_tmt_logo2.bin@0x0000 -o build/image_tmt_logo2.exo
bin\exomizer.exe level -M256 -c build/image_wsm_graf.bin@0x0000 -o build/image_wsm_graf.exo
bin\exomizer.exe level -M256 -c build/image_bbc_owl.bin@0x0000 -o build/image_bbc_owl.exo

rem bin\exomizer.exe level -M256 build/slide_dates.bin@0x0000 -o build/slide_dates.exo
bin\exomizer.exe level -M256 -c build/slide_beach.bin@0x0000 -o build/slide_beach.exo
bin\exomizer.exe level -M256 -c build/slide_chips.bin@0x0000 -o build/slide_chips.exo
bin\exomizer.exe level -M256 -c build/slide_floppies.bin@0x0000 -o build/slide_floppies.exo
bin\exomizer.exe level -M256 -c build/slide_djset.bin@0x0000 -o build/slide_djset.exo
bin\exomizer.exe level -M256 -c build/slide_firealarm.bin@0x0000 -o build/slide_firealarm.exo
bin\exomizer.exe level -M256 -c build/slide_kitchen.bin@0x0000 -o build/slide_kitchen.exo
bin\exomizer.exe level -M256 -c build/slide_patarty.bin@0x0000 -o build/slide_patarty.exo

bin\exomizer.exe level -M256 -c data/anims/a.sine@0x0000 -o build/anim_sine.exo
bin\exomizer.exe level -M256 -c data/anims/a.atom@0x0000 -o build/anim_atom.exo
bin\exomizer.exe level -M256 -c data/anims/a.world@0x0000 -o build/anim_world.exo
bin\exomizer.exe level -M256 -c data/anims/a.hbars@0x0000 -o build/anim_hbars.exo
bin\exomizer.exe level -M256 -c data/anims/a.dbars@0x0000 -o build/anim_dbars.exo
bin\exomizer.exe level -M256 -c data/anims/a.burst@0x0000 -o build/anim_burst.exo
bin\exomizer.exe level -M256 -c data/anims/a.particl@0x0000 -o build/anim_particl.exo
bin\exomizer.exe level -M256 -c data/anims/a.rotor@0x0000 -o build/anim_rotor.exo
bin\exomizer.exe level -M256 -c data/anims/a.swirl@0x0000 -o build/anim_swirl.exo
bin\exomizer.exe level -M256 -c data/anims/a.tunnel@0x0000 -o build/anim_tunnel.exo
bin\exomizer.exe level -M256 -c data/anims/a.vupal@0x0000 -o build/anim_vupal.exo
bin\exomizer.exe level -M256 -c data/anims/palette_shift_test.bin@0x0000 -o build/anim_shift.exo

bin\exomizer.exe level -M256 -c build/anim_turbulent.bin@0x0000 -o build/anim_turbulent.exo
bin\exomizer.exe level -M256 -c build/anim_triangle.bin@0x0000 -o build/anim_triangle.exo
bin\exomizer.exe level -M256 -c build/anim_claw.bin@0x0000 -o build/anim_claw.exo
bin\exomizer.exe level -M256 -c build/anim_star.bin@0x0000 -o build/anim_star.exo
bin\exomizer.exe level -M256 -c build/anim_circle.bin@0x0000 -o build/anim_circle.exo
bin\exomizer.exe level -M256 -c build/anim_faces.bin@0x0000 -o build/anim_faces.exo
bin\exomizer.exe level -M256 -c build/anim_square.bin@0x0000 -o build/anim_square.exo
bin\exomizer.exe level -M256 -c build/anim_kaleidoscope.bin@0x0000 -o build/anim_kaleidoscope.exo
