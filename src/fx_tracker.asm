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

.events_init
{
    lda #LO(event_data-1)
    sta events_load_byte+1
    lda #HI(event_data-1)
    sta events_load_byte+2
}
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

.events_update
{
    \\ Process an event as soon as the delay reaches 0.
    dec events_delay
    bne return
    
    lda events_delay+1
    beq process_event
    dec events_delay+1

    .return
    rts

    .process_event
    \\ Don't process events with zero value.
    EVENTS_GET_BYTE
    beq no_event
    sta events_data
    jsr events_handler
    .no_event

    \\ Get the delay to the next event.
    jsr events_set_delay

    \\ If this is zero then loop.
    bcc return

    jmp events_init
}

; A = event number
.events_handler
{
    tay
    and #&f0:
    lsr a:lsr a:tax
    lda event_fn_table+0, X
    sta jmp_to_handler+1
    lda event_fn_table+1, X
    sta jmp_to_handler+2
    tya
    and #&0f
    .jmp_to_handler
    jmp &FFFF
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
    EQUW handle_image,          preload_image   ; &1y   y = image no.
    EQUW handle_anim,           preload_image   ; &2y
    EQUW handle_set_colour,     0               ; &3y   y = colour no.
    EQUW handle_special_fx,     preload_special_fx  ; &4y
    EQUW do_nothing,            0               ; &5y
    EQUW do_nothing,            0               ; &6y
    EQUW do_nothing,            0               ; &7y
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

; A = image no.
.preload_image
{
    tax
    ldy assets_table_HI, X
    lda assets_table_LO, X
    tax
    lda next_buffer_HI
    jmp set_task_decrunch    
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
    lda tracker_pattern
    jsr debug_write_hex_spc
    lda tracker_line
    jsr debug_write_hex_spc
    lda events_data
    jsr debug_write_hex_spc
    lda preload_id
    jsr debug_write_hex_spc
    rts
}
ENDIF

.event_data
incbin "build/events.bin"
