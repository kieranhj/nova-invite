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
    CHECK_TASK_NOT_RUNNING

    lda #LO(special_fx_static_update)
    sta do_per_frame_fn+1
    lda #HI(special_fx_static_update)
    sta do_per_frame_fn+2

    lda #1: sta special_fx_vars+0
    jmp display_next_buffer_as_mode8
}

.special_fx_static_update
{
    dec special_fx_vars+0
    bne return

    lda static_bg_colour
    jsr set_all__palette

    ldy #8              ; static density
    .loop
    RND16
    tax
    lda mod15_plus1_asl4_table, X
    ora static_fg_colour
    SET_PALETTE_REG
    dey
    bpl loop

    lda #2              ; speed
    sta special_fx_vars+0

    .return
    rts
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
    pha
    SWRAM_SELECT SLOT_MUSIC     ; fixed SWRAM! TODO!
    ldx #LO(exo_anims_hbars)
    ldy #HI(exo_anims_hbars)
    pla; A contains next_buffer_HI
    jmp decrunch_to_page_A
}

.prepare_dbars
{
    pha
    SWRAM_SELECT SLOT_MUSIC     ; fixed SWRAM! TODO!
    ldx #LO(exo_anims_dbars)
    ldy #HI(exo_anims_dbars)
    pla; A contains next_buffer_HI
    jmp decrunch_to_page_A
}

.set_small_bars_colour
{
    sec
    sbc #&0A
    asl a:tax
    lda small_bars_ramps+0,X
    sta special_fx_bars_ramp1+1
    lda small_bars_ramps+1,X
    sta special_fx_bars_ramp1+2
    rts

    .small_bars_ramps
    EQUW anims_ramp_small_bars1
    EQUW anims_ramp_small_bars2
    EQUW anims_ramp_small_bars3
    EQUW anims_ramp_small_bars4
}

.set_large_bars_colour
{
    sec
    sbc #&0E
    asl a:tax
    lda large_bars_ramps+0,X
    sta special_fx_bars_ramp2+1
    lda large_bars_ramps+1,X
    sta special_fx_bars_ramp2+2
    rts

    .large_bars_ramps
    EQUW anims_ramp_large_bars1
    EQUW anims_ramp_large_bars2
    EQUW anims_ramp_large_bars3
    EQUW anims_ramp_large_bars4
}

.handle_copper_bars
{
    CHECK_TASK_NOT_RUNNING
    jsr set_mode_8
    jsr set_all_black_palette

    lda #3:sta special_fx_vars+0
    lda #11:sta special_fx_vars+1

    lda #LO(special_fx_bars_update)
    sta do_per_frame_fn+1
    lda #HI(special_fx_bars_update)
    sta do_per_frame_fn+2

    jsr set_per_irq_do_nothing
    jmp display_next_or_prev_buffer
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
    ora anims_ramp_small_bars1, Y
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
    ora anims_ramp_large_bars1, Y
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

; A = next screen buffer HI
; X = display screen buffer HI
; Y = prev screen buffer HI
.prepare_vubars
{
    PHA
    SWRAM_SELECT SLOT_MUSIC     ; fixed SWRAM! TODO!
    ldx #LO(exo_anims_vupal)
    ldy #HI(exo_anims_vupal)
    PLA ; A contains next_buffer_HI
    jmp decrunch_to_page_A
}

.handle_vubars
{
    CHECK_TASK_NOT_RUNNING
    jsr set_mode_8

    lda #LO(special_fx_vubars_beat)
    sta do_per_frame_fn+1
    lda #HI(special_fx_vubars_beat)
    sta do_per_frame_fn+2

    ldx #LO(special_fx_vubars_update)
    ldy #HI(special_fx_vubars_update)
    jsr set_per_irq_fn

    ldx #3
    .loop
    lda #0
    sta special_fx_vars+0, X        ; beat bar value
    lda #0
    sta special_fx_vars+4, X        ; beat bar fade?
    dex
    bpl loop

    jmp display_next_or_prev_buffer
}

.set_vubars_colour
{
    sec
    sbc #6
    asl a
    tax
    lda vubars_ramps+0, X
    sta vubars_read_green+1

    lda vubars_ramps+1, X
    sta vubars_read_green+2
    rts

    .vubars_ramps
    EQUW anims_ramp_vubars_1
    EQUW anims_ramp_vubars_2
    EQUW anims_ramp_vubars_3
    EQUW anims_ramp_vubars_4
}

special_fx_vubars_reg_copy = &A0

.special_fx_vubars_beat
{
    jsr set_all_black_palette

    \\ TONE3 (noise) doesn't have a HI byte so make one.
    lda VGM_FX_TONE3_LO
    sta VGM_FX_TONE2_HI+1

    ldx #3
    .loop
    \\ Only fade if no noise.
    lda special_fx_vars+4, X
    beq already_zero

    \\ Reduce beat bar length.
    lda special_fx_vars, X
    beq already_zero
    sec
    sbc #1
    sta special_fx_vars, X
    bne already_zero

    \\ Once reached zero cancel fade.
    sta special_fx_vars+4, X
    .already_zero

    \\ Check for new beats.
    lda vgm_fx+VGM_FX_TONE0_HI, X           ; current tone value for channel X
    cmp special_fx_vubars_reg_copy+VGM_FX_TONE0_HI, X       ; previous tone value for channel X
    bne make_beat

    lda vgm_fx+VGM_FX_TONE0_LO, X           ; current tone value for channel X
    cmp special_fx_vubars_reg_copy+VGM_FX_TONE0_LO, X       ; previous tone value for channel X
    bne make_beat

    lda vgm_fx+VGM_FX_VOL0, X               ; current volume value for channel X
    cmp special_fx_vubars_reg_copy+VGM_FX_VOL0, X       ; previous volume value for channel X
    bne make_beat

    .loop_continue
    dex
    bpl loop

; hack status bar to show vgm_fx registers.
;    SELECT_DEBUG_SLOT
;    jsr debug_reset_writeptr

    ldx #11
    .copy_loop
    lda vgm_fx, X
    sta special_fx_vubars_reg_copy, X

IF 0    ; hack status bar to show vgm_fx registers.
    stx temp
    ldx debug_show_status
    beq no_debug
    jsr debug_write_hex_spc
    .no_debug
    ldx temp
ENDIF

    dex
    bpl copy_loop
;    RESTORE_SLOT
    rts

    .make_beat
    \\ Make a beat.
    sec
    lda #15
    sbc vgm_fx+VGM_FX_VOL0, X
    beq fade_if_vol_zero            ; don't set bar to zero, let it fade.

    cmp special_fx_vars, X          ; don't set bar length lower than current value.
    bcc loop_continue

    sta special_fx_vars, X          ; otherwise set bar length to volume level.
    bne loop_continue

    .fade_if_vol_zero
    lda #&ff
    sta special_fx_vars+4, X        ; set bar to fade.
    bne loop_continue
}

.vubars_do_pal
{
    sta temp+1
    .green_loop
    cpx temp
    bcs done_green
    lda mult16_table, X
    .^vubars_read_green
    ora anims_ramp_vubars_1, Y
    SET_PALETTE_REG
    inx
    cpx temp+1
    bcc green_loop
    .done_green
    rts
}

; called per irq
.special_fx_vubars_update
{
    ldx irq_section                 ; 3 -> 0
    lda special_fx_vars, X
    sta temp

    ldx #1
    ldy #0
    lda #9:jsr vubars_do_pal

    iny
    lda #12:jsr vubars_do_pal

    iny
    lda #16:jsr vubars_do_pal

    iny
    lda #16:sta temp
    jmp vubars_do_pal
}
