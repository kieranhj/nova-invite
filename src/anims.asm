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
    {
        bne ok
        DEBUG_ERROR debug_msg_error_ramp
        rts
        .ok
    }
    ENDIF
    sta anims_ramp_ptr+1
    lda anims_ramp_table+0, X
    sta anims_ramp_ptr

    lda anims_ramp_table+2, X
    sta anims_ramp_length

    .return
    rts
}

; A = &MS where M = anim mode and S = anims speed
.anims_set_mode_and_speed
{
    tax
    and #&0f
    sta anims_frame_speed

    txa:and #&f0:lsr a:lsr a:tax
    lda anims_mode_table+1, X
    IF _DEBUG
    {
        bne ok
        DEBUG_ERROR debug_msg_error_mode
        rts
        .ok
    }
    ENDIF
    sta anim_frame_update_fn+2
    lda anims_mode_table+0, X
    sta anim_frame_update_fn+1

    ; zero speed means manual cycle
    lda anims_frame_speed
    bne not_zero_speed
    lda #1:sta anims_frame_delay
    bne return  ; don't set start value with manual cycle

    .not_zero_speed
    ; optional start value for index
    lda anims_mode_table+2, X
    bmi return
    sta anims_colour_index

    .return
    rts
}

; return C=1 if the animation was updated.
.anims_frame_update
{
    clc
    lda anims_frame_delay
    beq return

    dec anims_frame_delay
    bne return

    .^anim_frame_update_fn
    jsr anim_loop_forwards
    
    lda anims_frame_speed
    sta anims_frame_delay
    sec
    .return
    rts
}

; updates N animation frames only when triggered.
.anims_triggered_update
{
    lda anims_trigger_frames
    bne do_update

    \\ No update, no colour.
    jmp set_all_black_palette

    .do_update
    jsr anims_frame_update
    bcc return

    dec anims_trigger_frames

    .return
    rts
}

; A = &IF where I = starting palette index and F = number of animation frames to run for
.anims_trigger
{
    tax
    and #&0f
    sta anims_trigger_frames

    txa
    lsr a:lsr a:lsr a:lsr a
    sta anims_colour_index
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
    SET_PALETTE_REG

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
    SET_PALETTE_REG

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
    SET_PALETTE_REG

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
    SET_PALETTE_REG
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
    SET_PALETTE_REG

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
    SET_PALETTE_REG
    iny
    cpy anims_ramp_length
    bcc loop
    rts
}
