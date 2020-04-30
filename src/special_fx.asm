\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	SPECIAL FX
\ ******************************************************************

; A = next screen buffer HI
; X = display screen buffer HI
; Y = prev screen buffer HI
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

quad_line_count = temp+0
quad_temp_y = temp+1
quad_temp_byte = temp+2
quad_writeptr = temp+3

; A = next screen buffer HI
; X = display screen buffer HI
; Y = prev screen buffer HI
.prepare_quad_image
{
    sta writeptr+1
    stx readptr+1

    lda #0
    sta writeptr
    sta quad_writeptr
    sta readptr

    clc
    lda writeptr+1
    adc #HI(SCREEN_SIZE_BYTES/2)
    sta quad_writeptr+1

    lda #16*8
    sta quad_line_count
    .loop
    jsr quad_copy_image_line

    {
        inc writeptr
        inc quad_writeptr
        lda writeptr
        and #7
        bne no_carry
        inc writeptr+1
        inc quad_writeptr+1
        lda #0
        sta writeptr
        sta quad_writeptr
        .no_carry
    }
    {
        inc readptr
        inc readptr
        lda readptr
        and #7
        bne no_carry
        inc readptr+1
        lda #0
        sta readptr
        .no_carry
    }

    dec quad_line_count
    bne loop

    rts
}

.quad_copy_image_line
{
    ldy #0
    .loop
    sty quad_temp_y

    lda (readptr), Y
    and #&AA    ; alt pixels
    tax
    lda alt_pixels_to_lh, X
    sta quad_temp_byte

    lda quad_temp_y:clc:adc #8:tay

    lda (readptr), Y
    and #&AA    ; alt pixels
    tax
    lda alt_pixels_to_lh, X
    lsr a:lsr a:lsr a:lsr a
    ora quad_temp_byte
    sta quad_temp_byte

    lda quad_temp_y:lsr a:tay
    lda quad_temp_byte
    sta (writeptr), Y
    sta (quad_writeptr), Y

    lda quad_temp_y:lsr a:clc:adc #&80:tay
    lda quad_temp_byte
    sta (writeptr), Y
    sta (quad_writeptr), Y

    lda quad_temp_y:clc:adc #16:tay
    bne loop
    rts
}
