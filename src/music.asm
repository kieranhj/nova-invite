\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	MUSIC MODULE
\ ******************************************************************

.music_code_start

IF 0
.music_silent
{
sei								; in case it's playing...
lda #$0f
jsr fiddle_vgm_register_headers
jsr sn_reset
cli
rts
}

.music_loud
{
lda #$00
jsr fiddle_vgm_register_headers
rts
}

.fiddle_vgm_register_headers
{
sta ora_bits+1
ldx #4
.loop
lda vgm_register_headers,x
and #$f0
.ora_bits:ora #$00
sta vgm_register_headers,x
inx
cpx #8
bne loop
rts
}
ENDIF

INCLUDE "lib/vgmplayer.asm"
INCLUDE "lib/exomiser.asm"
.music_code_end

.music_data_start
; no need for VGC data to be page aligned.
.vgc_data_tune
INCBIN "data/acid_demo.vgm.bin.exo"
.music_data_end

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------"
PRINT "MUSIC"
PRINT "------"
PRINT "CODE size =", ~music_code_end-music_code_start
PRINT "DATA size =",~music_data_end-music_data_start
PRINT "------"
