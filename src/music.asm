\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	MUSIC MODULE
\ ******************************************************************

.music_code_start

.music_init_tune
{
    lda #hi(vgm_stream_buffers)
    ldx #lo(vgc_data_tune)
    ldy #hi(vgc_data_tune)
    sec ; loop
    jmp vgm_init
}

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

INCLUDE "lib/vgcplayer.asm"
.music_code_end

.music_data_start
PAGE_ALIGN
.vgc_data_tune
INCBIN "build/acid_test.vgc"
.music_data_end

\ ******************************************************************
\ *	Space reserved for runtime buffers not preinitialised
\ ******************************************************************

.music_bss_start

PAGE_ALIGN
.vgm_buffer_start
; reserve space for the vgm decode buffers (8x256 = 2Kb)
.vgm_stream_buffers
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
.vgm_buffer_end

.music_bss_end

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------"
PRINT "MUSIC"
PRINT "------"
PRINT "CODE size =", ~music_code_end-music_code_start
PRINT "DATA size =",~music_data_end-music_data_start
PRINT "BSS size =",~music_bss_end-music_bss_start
PRINT "------"
