\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	SPECIAL FX
\ ******************************************************************

.prepare_static
{
    sta writeptr+1
    lda #0
    sta writeptr

    ldx #HI(SCREEN_SIZE_BYTES)
    ldy #0
    .loop
    RND16
    sta (writeptr), Y
    iny
    bne loop

    inc writeptr+1
    dex
    bne loop
    rts
}

.handle_static
{
    lda #&0B            ; anim_ramp_static
    jsr anims_set_ramp

    lda #&62            ; random mode, speed = 2
    jsr anims_set_mode_and_speed

    jmp handle_anim
}
