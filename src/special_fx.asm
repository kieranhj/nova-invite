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

    lda #0              ; dummy anim no.
    jmp handle_anim
}

; A = next screen buffer HI
; X = display screen buffer HI
; Y = prev screen buffer HI
.prepare_quad_image
{
    sta writeptr+1
    stx readptr+1
    ldx #LO(quad_copy_image_line)
    ldy #HI(quad_copy_image_line)
    jmp quad_display_to_next
}

; A = next screen buffer HI
; X = display screen buffer HI
; Y = prev screen buffer HI
.prepare_quad_anim
{
    sta writeptr+1
    stx readptr+1
    ldx #LO(quad_copy_anim_line)
    ldy #HI(quad_copy_anim_line)
    jmp quad_display_to_next
}

quad_line_count = temp+0
quad_temp_y = temp+1
quad_temp_byte = temp+2
quad_writeptr = temp+3

.quad_display_to_next
{
    stx jmp_copy_fn+1
    sty jmp_copy_fn+2

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

    .jmp_copy_fn
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

.quad_copy_anim_line
{
    ldy #0
    .loop
    sty quad_temp_y

    lda (readptr), Y
    tax
    and #&AA    ; lh pixel
    bne use_lh
    txa
    and #&55    ; use rh pixel
    asl a
    .use_lh
    sta quad_temp_byte

    lda quad_temp_y:clc:adc #8:tay

    lda (readptr), Y
    tax
    and #&AA    ; lh pixel
    lsr a       ; make rh pixel
    bne use_lh2
    txa
    and #&55    ; use rh pixel
    .use_lh2
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

.prepare_hbars
{
    ldx #7                      ; fixed SWRAM! TODO!
    stx &f4:stx &fe30
    ldx #LO(exo_anims_hbars)
    ldy #HI(exo_anims_hbars)
    ; A contains next_buffer_HI
    jmp decrunch_to_page_A
}

.prepare_dbars
{
    ldx #7                      ; fixed SWRAM! TODO!
    stx &f4:stx &fe30
    ldx #LO(exo_anims_dbars)
    ldy #HI(exo_anims_dbars)
    ; A contains next_buffer_HI
    jmp decrunch_to_page_A
}

.handle_hbars
{
    CHECK_TASK_NOT_RUNNING
    jsr set_mode_8
    jsr set_all_black_palette

    lda #3:sta special_fx_vars+0
    lda #11:sta special_fx_vars+1

    lda #LO(anims_ramp_hbars1)
    sta special_fx_bars_ramp1+1
    lda #HI(anims_ramp_hbars1)
    sta special_fx_bars_ramp1+2

    lda #LO(anims_ramp_hbars2)
    sta special_fx_bars_ramp2+1
    lda #HI(anims_ramp_hbars2)
    sta special_fx_bars_ramp2+2

    lda #LO(special_fx_bars_update)
    sta do_per_frame_fn+1
    lda #HI(special_fx_bars_update)
    sta do_per_frame_fn+2

    jmp display_next_buffer
}

.handle_dbars
{
    CHECK_TASK_NOT_RUNNING
    jsr set_mode_8
    jsr set_all_black_palette

    lda #3:sta special_fx_vars+0
    lda #11:sta special_fx_vars+1

    lda #LO(anims_ramp_dbars1)
    sta special_fx_bars_ramp1+1
    lda #HI(anims_ramp_dbars1)
    sta special_fx_bars_ramp1+2

    lda #LO(anims_ramp_dbars2)
    sta special_fx_bars_ramp2+1
    lda #HI(anims_ramp_dbars2)
    sta special_fx_bars_ramp2+2

    lda #LO(special_fx_bars_update)
    sta do_per_frame_fn+1
    lda #HI(special_fx_bars_update)
    sta do_per_frame_fn+2

    jmp display_next_buffer
}

.special_fx_bars_update
{
    jsr set_all_black_palette

    ldy #0
    .loop1
    tya
    clc
    adc special_fx_vars+0
    asl a:asl a:asl a:asl a
    .^special_fx_bars_ramp1
    ora anims_ramp_hbars1, Y
    SET_PALETTE_REG
    eor #&80
    SET_PALETTE_REG
    iny
    cpy #3
    bcc loop1
    
    ldy #0
    .loop2
    tya
    clc
    adc special_fx_vars+1
    asl a:asl a:asl a:asl a
    .^special_fx_bars_ramp2
    ora anims_ramp_hbars2, Y
    SET_PALETTE_REG
    iny
    cpy #5
    bcc loop2

    inc special_fx_vars+1
    lda special_fx_vars+1
    and #1
    beq return
    inc special_fx_vars+0
    .return
    rts
}
