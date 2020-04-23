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
.events_get_delay
{
    EVENTS_GET_BYTE
    sta events_delay
    EVENTS_GET_BYTE
    sta events_delay+1

    \\ Call preload fn for next event.
    EVENTS_PEEK_BYTE

    tay
    and #&f0:
    lsr a:lsr a:tax
    lda event_fn_table+2, X
    sta jmp_to_preload+1
    lda event_fn_table+3, X
    sta jmp_to_preload+2
    tya
    and #&0f
    .jmp_to_preload
    jmp &FFFF
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
    jsr events_handler
    .no_event

    \\ Get the delay to the next event.
    jsr events_get_delay

    \\ If this is zero then loop.
    lda events_delay
    ora events_delay+1
    bne return

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
    jmp set_fg_colour
}

.event_fn_table
{
\\ Event handler and preload fn per event type &xy
    EQUW handle_set_colour,     do_nothing  ; &0y
    EQUW handle_image,          do_nothing  ; &1y
    EQUW handle_anim,           do_nothing  ; &2y
    EQUW handle_set_colour,     do_nothing  ; &3y
    EQUW handle_special_fx,     do_nothing  ; &4y
    EQUW do_nothing,            do_nothing  ; &5y
    EQUW do_nothing,            do_nothing  ; &6y
    EQUW do_nothing,            do_nothing  ; &7y
    EQUW do_nothing,            do_nothing  ; &8y
    EQUW do_nothing,            do_nothing  ; &9y
    EQUW do_nothing,            do_nothing  ; &Ay
    EQUW do_nothing,            do_nothing  ; &By
    EQUW do_nothing,            do_nothing  ; &Cy
    EQUW do_nothing,            do_nothing  ; &Dy
    EQUW do_nothing,            do_nothing  ; &Ey
    EQUW do_nothing,            do_nothing  ; &Fy
}

.handle_ctrl_code
.handle_image
.handle_anim
.handle_special_fx
.do_nothing
{
    rts
}

.event_data
incbin "build/events.bin"
