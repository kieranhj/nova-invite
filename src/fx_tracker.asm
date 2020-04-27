\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FX TRACKER MODULE
\ ******************************************************************

\\ Update tracker counters
.fx_tracker_update
{
    ldx tracker_vsync
    inx
    cpx #TRACK_SPEED
    stx tracker_vsync
    bcc is_mid_line

    ldx #0
    stx tracker_vsync

    \\ Moved to new line in the pattern

    ldx tracker_line
    inx
    cpx #TRACK_PATTERN_LENGTH
    bcc same_pattern

    \\ Moved to new pattern
    inc tracker_pattern

    ldx #0
    .same_pattern
    stx tracker_line

    \\ Beat signature
    ldx #0
    lda tracker_line
    and #TRACK_LINES_PER_BEAT-1
    cmp #0
    bne not_0
    inx
    .not_0
    stx is_beat_line

    .is_mid_line
    rts
}

MACRO EVENTS_GET_BYTE
{
    jsr events_get_byte
}
ENDMACRO

MACRO EVENTS_SET_ADDRESS_XY
{
    stx events_load_byte+1
    sty events_load_byte+2
}
ENDMACRO

MACRO PRELOAD_GET_BYTE
{
    jsr preload_get_byte
}
ENDMACRO

MACRO PRELOAD_SET_ADDRESS_XY
{
    stx preload_load_byte+1
    sty preload_load_byte+2
}
ENDMACRO

MACRO EVENTS_PEEK_BYTE
{
    lda events_load_byte+1
    sta events_ptr
    lda events_load_byte+2
    sta events_ptr+1
    ldy #1
    lda (events_ptr), Y
}
ENDMACRO

; A = pattern no.
.events_get_pattern_address
{
    asl a
    tay
    lda event_data+2, Y         ; skip first two flag bytes
    sec
    sbc #1
    tax
    lda event_data+3, Y
    sbc #0
    tay
    rts
}

.events_init
{
    lda #0
    sta events_pattern
    sta preload_pattern

    jsr events_get_pattern_address

    EVENTS_SET_ADDRESS_XY
    PRELOAD_SET_ADDRESS_XY

    lda #1:sta events_delay
    jmp preload_update
}

IF 0
\\ drop through.
.events_set_delay
{
    EVENTS_GET_BYTE
    sta events_delay
    EVENTS_GET_BYTE
    sta events_delay+1

    ora events_delay
    bne find_next_preload

    sec
    rts

    .find_next_preload
    \\ Call preload fn for next event that has one.
    lda events_load_byte+1
    sta events_ptr
    lda events_load_byte+2
    sta events_ptr+1
    ldy #1

    .peek_loop
    lda (events_ptr), Y     ; peek event value

    cmp preload_id          ; check if we already did this one
    beq end_of_events

    and #&f0
    lsr a:lsr a:tax
    lda event_fn_table+3, X
    beq no_preload

    sta jmp_to_preload+2
    lda event_fn_table+2, X
    sta jmp_to_preload+1
    
    lda (events_ptr), Y
    sta preload_id

    and #&0f
    clc
    .jmp_to_preload
    jmp &FFFF

    .no_preload
    iny
    lda (events_ptr), Y     ; next delay LO
    iny
    ora (events_ptr), Y     ; next delay HI
    beq end_of_events

    iny
    bne peek_loop

    .end_of_events
    clc
    rts
}
ENDIF

\\ Can move these to ZP if we need the cycles...
.events_get_byte
{
    inc events_load_byte+1
    bne ok
    inc events_load_byte+2
    .ok
}
.events_load_byte
    lda &FFFF
    rts

.preload_get_byte
{
    inc preload_load_byte+1
    bne ok
    inc preload_load_byte+2
    .ok
}
.preload_load_byte
    lda &FFFF
    rts

.events_update
{
    \\ Process an event as soon as the line delay reaches 0.
    dec events_delay
    bne return

    .process_event
    lda events_line
    cmp #TRACK_PATTERN_LENGTH
    bcc not_finished_pattern

    lda #0:sta events_line

    \\ We finished the pattern so load the next one!
    inc events_pattern

    .get_next_pattern
    lda events_pattern
    jsr events_get_pattern_address
    cpy #&ff
    bne set_new_pattern

    \\ Patterns looped!
    lda #0:sta events_pattern
    beq get_next_pattern

    .set_new_pattern
    EVENTS_SET_ADDRESS_XY

    .not_finished_pattern
    EVENTS_GET_BYTE
    bpl process_line

    \\ Value >= 128 => Value-127 empty cells
    sec
    sbc #127
    sta events_delay
    bne return          ; always taken

    .process_line
    IF _DEBUG
    {
        cmp #120        ; No note.
        beq ok
        BRK
        .ok
    }
    ENDIF
    EVENTS_GET_BYTE     ; No instrument
    IF _DEBUG
    {
        beq ok
        BRK
        .ok
    }
    ENDIF

    .events_loop
    EVENTS_GET_BYTE
    cmp #10             ; Effect number: 10
    bne done_events

    EVENTS_GET_BYTE     ; Effect value: low byte = data
    sta events_data

    EVENTS_GET_BYTE     ; Effect value: high byte = code
    sta events_code

    \\ Events handler
    asl a:asl a:tax
    lda event_fn_table+0, X
    sta jmp_to_handler+1
    lda event_fn_table+1, X
    sta jmp_to_handler+2
    lda events_data
    .jmp_to_handler
    jsr &FFFF

    jmp events_loop

    .done_events
    \\ Process next line next update
    lda #1:sta events_delay

    \\ Poll the preload system
    jsr preload_update

    .return
    inc events_line
    rts
}

.preload_update
{
    \\ We only need to process the next preload when the event
    \\ update has caught up with the current preload position.
    lda preload_load_byte+1
    cmp events_load_byte+1
    bne return
    lda preload_load_byte+2
    cmp events_load_byte+2
    bne return

    lda #0:sta preload_id

    .line_loop
    lda preload_line
    cmp #TRACK_PATTERN_LENGTH
    bcc not_finished_pattern

    lda #0:sta preload_line

    \\ We finished the pattern so load the next one!
    inc preload_pattern

    .get_next_pattern
    lda preload_pattern
    jsr events_get_pattern_address
    cpy #&ff
    bne set_new_pattern

    \\ Patterns looped!
    lda #0:sta preload_pattern
    beq get_next_pattern

    .set_new_pattern
    PRELOAD_SET_ADDRESS_XY

    .not_finished_pattern
    PRELOAD_GET_BYTE
    bpl process_line

    \\ Skip empty cells.
    sec
    sbc #128
    clc
    adc preload_line
    sta preload_line
    bne line_processed

    .process_line
    IF _DEBUG
    {
        cmp #120        ; No note.
        beq ok
        BRK
        .ok
    }
    ENDIF
    PRELOAD_GET_BYTE     ; No instrument
    IF _DEBUG
    {
        beq ok
        BRK
        .ok
    }
    ENDIF

    .preload_loop
    PRELOAD_GET_BYTE
    cmp #10             ; Effect number: 10
    bne line_processed

    PRELOAD_GET_BYTE    ; Effect value: low byte = data
    sta preload_data

    PRELOAD_GET_BYTE    ; Effect value: high byte = code
    sta preload_code
    asl a:asl a:tax
    lda event_fn_table+3, X
    beq no_preload

    sta jmp_to_preload+2
    lda event_fn_table+2, X
    sta jmp_to_preload+1

    lda preload_data
    .jmp_to_preload
    jsr &FFFF

    inc preload_id

    .no_preload
    jmp preload_loop

    .line_processed
    inc preload_line

    \\ Continue until we preloaded something.
    lda preload_id
    beq line_loop

    .return
    rts
}

.handle_set_colour
{
    eor #7
    sta last_fg_colour
    jmp set_mode4_fg_colour
}

.event_fn_table
{
\\ Event handler and preload fn per event type &xy
    EQUW do_nothing,            0               ; &0y
    EQUW handle_image,          preload_image   ; &1y set image y = image no.
    EQUW handle_anim,           preload_anim    ; &2y set anim y = anim no.
    EQUW handle_set_colour,     0               ; &3y set fg colour y = colour no.
    EQUW handle_special_fx, preload_special_fx  ; &4y special Fx 
    EQUW anims_set_ramp,        0               ; &5y set anim ramp y = ramp no.
    EQUW anims_set_speed,       0               ; &6y set anim speed
    EQUW anims_set_mode,        0               ; &7y set anim mode
    EQUW do_nothing,            0               ; &8y
    EQUW do_nothing,            0               ; &9y
    EQUW do_nothing,            0               ; &Ay
    EQUW do_nothing,            0               ; &By
    EQUW do_nothing,            0               ; &Cy
    EQUW do_nothing,            0               ; &Dy
    EQUW do_nothing,            0               ; &Ey
    EQUW do_nothing,            0               ; &Fy
}

.handle_ctrl_code
.do_nothing
{
    rts
}

; A = image no.
.handle_image
{
    CHECK_TASK_NOT_RUNNING      ; Need to think more about this.
    jsr set_mode_4
    lda last_fg_colour:jsr set_mode4_fg_colour
    lda #PAL_black:jsr set_mode4_bg_colour
    jsr set_per_frame_do_nothing
    jmp display_next_buffer
}

MACRO SET_TASK_FN func
{
    lda #LO(func)
    sta do_task_jmp+1
    lda #HI(func)
    sta do_task_jmp+2
    inc task_request
}
ENDMACRO

; A = image no.
.preload_image
{
    sta do_task_load_X+1
    lda next_buffer_HI
    sta do_task_load_A+1
    SET_TASK_FN decrunch_image
    rts
}

; A = to_addr
; X = image no.
.decrunch_image
{
    pha
    txa:asl a:tax 
    ldy image_table+1, X
    lda image_table+0, X
    tax
    lda #5
    sta &f4:sta &fe30
    pla
    jmp decrunch_to_page_A
}

; A = anim no.
.preload_anim
{
    sta do_task_load_X+1
    lda next_buffer_HI
    sta do_task_load_A+1
    SET_TASK_FN decrunch_anim
    rts
}

; A = to_addr
; X = anim no.
.decrunch_anim
{
    pha
    txa:asl a:asl a:tax 
    lda anims_table+2, X
    sta &f4:sta &fe30

    ldy anims_table+1, X
    lda anims_table+0, X
    tax
    pla
    jmp decrunch_to_page_A
}

; A = anim no.
.handle_anim
{
    CHECK_TASK_NOT_RUNNING      ; Need to think more about this.
    pha
    jsr set_mode_8
    jsr set_mode8_default_palette
    pla
    jsr anims_set_anim
    jmp display_next_buffer
}

; A = fx no.
.preload_special_fx
{
    CHECK_TASK_NOT_RUNNING
    ; just static for now.
    lda next_buffer_HI
    sta do_task_load_A+1

    lda #LO(plot_static)
    sta do_task_jmp+1

    lda #HI(plot_static)
    sta do_task_jmp+2

    inc task_request
    rts
}

.handle_special_fx
{
    jsr set_mode_4
    lda #PAL_white:jsr set_mode4_fg_colour
    lda #PAL_black:jsr set_mode4_bg_colour
    jsr set_per_frame_do_nothing
    jmp display_next_buffer
}

MACRO RND
{
    LDA seed
    ASL A
    ASL A
    CLC
    ADC seed
    CLC
    ADC #&45
    STA seed
}
ENDMACRO

MACRO RND16
{
    lda seed+1
    lsr a
    rol seed
    bcc no_eor
    eor #&b4
    .no_eor
    sta seed+1
    eor seed
}
ENDMACRO

.plot_static
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

IF _DEBUG
.fx_tracker_show_debug
{
    jsr debug_reset_writeptr
    lda events_pattern
    jsr debug_write_hex
    lda events_line
    jsr debug_write_hex_spc
    lda events_code
    jsr debug_write_hex
    lda events_data
    jsr debug_write_hex_spc

    lda preload_pattern
    jsr debug_write_hex
    lda preload_line
    jsr debug_write_hex_spc
    lda preload_code
    jsr debug_write_hex
    lda preload_data
    jsr debug_write_hex_spc
    rts
}
ENDIF
