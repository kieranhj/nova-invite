\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
\ ******************************************************************

; A = ramp no.
.anims_set_ramp
{
    asl a:asl a
    tax

    lda anims_ramp_table+1, X
    IF _DEBUG
    bne ok
    brk
    .ok
    ENDIF
    sta anims_ramp_ptr+1
    lda anims_ramp_table+0, X
    sta anims_ramp_ptr

    lda anims_ramp_table+2, X
    sta anims_ramp_length

    .return
    rts
}

; A = delay
.anims_set_speed
{
    sta anims_frame_speed
    rts
}

; A = anim mode
.anims_set_mode
{
    asl a:asl a:tax
    lda anims_mode_table+1, X
    IF _DEBUG
    bne ok
    brk
    .ok
    ENDIF
    sta anim_frame_update_fn+2
    lda anims_mode_table+0, X
    sta anim_frame_update_fn+1

    ; optional start value for index
    lda anims_mode_table+2, X
    bmi return
    sta anims_colour_index

    .return
    rts
}

.anims_frame_update
{
    dec anims_frame_delay
    bne return

    .^anim_frame_update_fn
    jsr anim_loop_forwards
    
    lda anims_frame_speed
    sta anims_frame_delay

    .return
    rts
}

.anim_loop_forwards
{
    ldy #0
    .loop
    tya
    clc
    adc anims_colour_index
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    iny
    cpy anims_ramp_length
    bcc loop

    ldx anims_colour_index
    inx
    cpx #MOD15_MAX
    bcc ok
    ldx #0
    .ok
    stx anims_colour_index
    
    rts
}

.anim_ping_pong
{
    ldy #0
    .loop
    tya
    clc
    adc anims_colour_index
    tax

    lda ping_pong_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    iny
    cpy anims_ramp_length
    bcc loop

    ldx anims_colour_index
    inx
    cpx #PING_PONG_MAX
    bcc ok
    ldx #0
    .ok
    stx anims_colour_index
    
    rts
}

.anim_loop_backwards
{
    ldx anims_colour_index
    dex
    cpx #255
    bne ok
    ldx #MOD15_MAX-1
    .ok
    stx anims_colour_index

    ldy anims_ramp_length
    .loop
    tya
    clc
    adc anims_colour_index
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    dey
    bne loop

    rts
}

.anim_oneshot_forwards
{
    lda anims_colour_index
    bmi return

    ldy anims_ramp_length
    dey

    ldx anims_colour_index  ; go from 0->14 + ramp_length 
    .loop
    cpx #15
    bcs off_end

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21
    .off_end

    dey
    bmi done_loop
    dex
    bpl loop
    .done_loop
    inc anims_colour_index

    ; stop when last ramp reaches last colour.
    cpx #15
    bne return

    lda #128:sta anims_colour_index
   
    .return
    rts
}

.anim_oneshot_backwards
{
    lda anims_colour_index
    bmi return

    ldy anims_ramp_length
    dey

    ldx anims_colour_index
    .loop
    cpx #15
    bcs off_end

    \\ Flip the colour index to 14-x
    stx temp_x+1
    sec
    lda #14
    sbc temp_x+1
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    .temp_x
    ldx #0

    .off_end

    dey
    bmi done_loop
    dex
    bpl loop
    .done_loop
    inc anims_colour_index

    ; stop when last ramp reaches last colour.
    cpx #15
    bne return

    lda #128:sta anims_colour_index
   
    .return
    rts
}

.anim_random
{
    jsr set_all_black_palette
    ldy #1
    .loop
    RND16
    tax
    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21
    iny
    cpy anims_ramp_length
    bcc loop
    rts
}
