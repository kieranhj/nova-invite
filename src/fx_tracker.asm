\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FX TRACKER MODULE
\ ******************************************************************

.event_fn_table
{
\\ Event handler and preload fn per event type &xy
    EQUW handle_screen,             0                   ; c0 yy screen control y = command
    EQUW handle_image,              preload_image       ; c1 yy set image y = image no.
    EQUW handle_anim,               preload_anim        ; c2 yy set anim y = anim no.
    EQUW handle_set_colour,         0                   ; c3 yy set fg colour y = colour no.
    EQUW handle_special_fx,         preload_special_fx  ; c4 yy set special Fx y = fx no.
    EQUW anims_set_ramp,            0                   ; c5 yy set anim ramp y = ramp no.
    EQUW anims_set_mode_and_speed,  0                   ; c6 xy set anim mode x and speed y
    EQUW anims_trigger,             0                   ; c7 xy trigger anim from index x for y frames
    EQUW handle_image,              prepare_text        ; c8 yy write text yy = text block no.
    EQUW rotate_display_buffers,    preload_image       ; c9 yy load image to prev y = image no.
    EQUW rotate_display_buffers,    preload_anim        ; cA yy load anim to prev y = anim no.
;    EQUW do_nothing,            0               ; cB yy
;    EQUW do_nothing,            0               ; cC yy
;    EQUW do_nothing,            0               ; cD yy
;    EQUW do_nothing,            0               ; cE yy
;    EQUW do_nothing,            0               ; cF yy
}

MACRO EVENTS_SET_ADDRESS_XY
{
    stx events_ptr
    sty events_ptr+1
}
ENDMACRO

MACRO PRELOAD_SET_ADDRESS_XY
{
    stx preload_ptr
    sty preload_ptr+1
}
ENDMACRO

; A = pattern no.
.events_get_pattern_address
{
    asl a
    tay
    ldx event_data+0, Y
    lda event_data+1, Y
    tay
}
.another_return
    rts

.events_init
{
    lda #&ff
    sta events_frame
    sta events_line
    sta preload_line

    lda #0
    sta events_pattern
    sta preload_pattern

    jsr events_get_pattern_address
    EVENTS_SET_ADDRESS_XY
    PRELOAD_SET_ADDRESS_XY

    lda #1:sta events_delay

    lda #&11    ; default to forward loop at speed 1
    jsr anims_set_mode_and_speed

    jmp preload_update
}

.events_update
{
    \\ Update line number.
    inc events_line

    \\ Process an event as soon as the line delay reaches 0.
    dec events_delay
    bne another_return

    .process_event
    lda events_line
    cmp #TRACK_PATTERN_LENGTH
    bcc not_finished_pattern

    \\ We finished the pattern so load the next one!
    lda #0:sta events_line
    inc events_pattern

    .get_next_pattern
    lda events_pattern
    jsr events_get_pattern_address
    cpy #0                      ; 0 address
    bne set_new_pattern

    \\ Patterns looped!
    sty events_pattern
    beq get_next_pattern        ; always taken

    .set_new_pattern
    EVENTS_SET_ADDRESS_XY

    .not_finished_pattern
    ldy #0
    ; EVENTS_GET_BYTE
    lda (events_ptr), Y
    bpl process_line
    iny

    \\ Value >= 128 => Value-127 empty cells
    sec
    sbc #127
    sta events_delay
    bne return_update_ptr       ; always taken

    .process_line
    iny
    sta events_count
    IF _DEBUG
    {
        beq not_ok
        cmp #5
        bcc ok
        .not_ok
        BRK                     ; can't have > 4 events
        .ok
    }
    ENDIF

    .events_loop
    lda (events_ptr), Y:iny     ; EVENTS_GET_BYTE
    sta temp_data               ; Effect value: low byte = data

    lda (events_ptr), Y:iny     ; EVENTS_GET_BYTE
                                ; Effect value: high byte = code
    sty temp_y+1

    ; temp_code and temp_data
    jsr call_event_handler

    .temp_y
    ldy #0

    dec events_count
    bne events_loop

    \\ Process next line next update
    lda #1:sta events_delay

    .return_update_ptr
    \\ Update events_ptr
    {
        clc
        tya
        adc events_ptr
        sta events_ptr
        bcc no_carry
        inc events_ptr+1
        .no_carry
    }
}
.preload_return
    rts

; A = event code, uses temp_data
.call_event_handler
{
    sta temp_code

    \\ Lookup events handler fn.
    asl a:asl a:tax
    lda event_fn_table+3, X
    beq no_preload

    \\ If we have a preload then remember the last event.
    lda events_code:sta prev_code
    lda events_data:sta prev_data

    .no_preload
    lda event_fn_table+0, X
    sta jmp_to_handler+1
    lda event_fn_table+1, X
    sta jmp_to_handler+2

    ; A = events data passed to handler.
    lda temp_data
    .jmp_to_handler
    jsr &FFFF

    ; Update events vars afterwards - these are private!
    lda temp_code:sta events_code
    lda temp_data:sta events_data
    rts
}

; Switch back to the previous handler.
.call_prev_handler
{
    inc reverse_buffers
    lda prev_data
    sta temp_data
    lda prev_code
    jsr call_event_handler
    dec reverse_buffers
    rts
}

.preload_update
{
    \\ We only need to process the next preload when the event
    \\ update has caught up with the current preload position.
    lda preload_pattern
    cmp events_pattern
    bne preload_return
    lda preload_line
    cmp events_line
    bne preload_return

    lda #0:sta preload_id

    .line_loop
    ldx preload_line
    inx
    cpx #TRACK_PATTERN_LENGTH
    stx preload_line
    bcc not_finished_pattern

    lda #0:sta preload_line

    \\ We finished the pattern so load the next one!
    inc preload_pattern

    .get_next_pattern
    lda preload_pattern
    jsr events_get_pattern_address
    cpy #0
    bne set_new_pattern

    \\ Patterns looped!
    sty preload_pattern
    beq get_next_pattern        ; always taken

    .set_new_pattern
    PRELOAD_SET_ADDRESS_XY

    .not_finished_pattern
    ldy #0
    lda (preload_ptr), Y        ; PRELOAD_GET_BYTE
    bpl process_line
    iny

    \\ Skip empty cells.
    sec
    sbc #128
    clc
    adc preload_line
    sta preload_line
    bne line_processed

    .process_line
    iny
    sta preload_count
    IF _DEBUG
    {
        beq not_ok
        cmp #5
        bcc ok
        .not_ok
        BRK                     ; can't have > 4 events
        .ok
    }
    ENDIF

    .preload_loop
    lda (preload_ptr), Y:iny    ; PRELOAD_GET_BYTE
    sta preload_data    ; Effect value: low byte = data

    lda (preload_ptr), Y:iny    ; PRELOAD_GET_BYTE
    sta preload_code    ; Effect value: high byte = code

    asl a:asl a:tax
    lda event_fn_table+3, X
    beq no_preload

    sta jmp_to_preload+2
    lda event_fn_table+2, X
    sta jmp_to_preload+1

    sty temp_y+1
    lda preload_data
    .jmp_to_preload
    jsr &FFFF
    .temp_y
    ldy #0
    inc preload_id

    .no_preload
    dec preload_count
    bne preload_loop

    .line_processed
    \\ Update preload_ptr
    {
        clc
        tya
        adc preload_ptr
        sta preload_ptr
        bcc no_carry
        inc preload_ptr+1
        .no_carry
    }

    \\ Continue until we preloaded something.
    lda preload_id
    beq line_loop

    .return
    rts
}

.handle_set_colour
{
    tax
    and #&0f
    eor #7
    cpx #&10
    bcs not_fg
    \\ Image foreground colour
    sta last_fg_colour
    jmp set_mode4_fg_colour

    .not_fg
    cpx #&20
    bcs not_bg
    \\ Image background colour
    sta last_bg_colour
    jmp set_mode4_bg_colour

    .not_bg
    cpx #&30
    bcs not_static_fg
    \\ Static foreground colour
    sta static_fg_colour
    rts

    .not_static_fg
    cpx #&40
    bcs not_static_bg
    \\ Static background colour
    sta static_bg_colour
    rts

    .not_static_bg
    \\ Special Fx colours
    eor #7
    cpx #&50
    bcs not_vubars
    jmp set_vubars_colour

    .not_vubars
    cpx #&60
    bcs not_small_bars
    jmp set_small_bars_colour

    .not_small_bars
    jmp set_large_bars_colour
}

.handle_ctrl_code
.do_nothing
{
    rts
}

; A = image no.
.handle_image
{
    CHECK_TASK_NOT_RUNNING
    jsr set_mode_4
    lda last_fg_colour:jsr set_mode4_fg_colour
    lda last_bg_colour:jsr set_mode4_bg_colour
    jsr set_per_frame_do_nothing
    jsr set_per_irq_do_nothing
    jmp display_next_or_prev_buffer
}

MACRO REQUEST_TASK
{
    CHECK_TASK_NOT_RUNNING
    inc task_request
}
ENDMACRO

MACRO SET_TASK_FN func
{
    lda #LO(func)
    sta do_task_jmp+1
    lda #HI(func)
    sta do_task_jmp+2
    REQUEST_TASK
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
    txa:asl a:asl a:tax 
    ldy image_table+2, X
    ; SWRAM_SELECT
    lda swram_slots_base, y
    sta &f4:sta &fe30

    ldy image_table+1, X
    IF _DEBUG
    {
        bmi ok
        DEBUG_ERROR debug_msg_error_image
        pla:rts
        .ok
    }
    ENDIF
    lda image_table+0, X
    tax
    pla
    jmp decrunch_to_page_A
}

; A = anim no.
.preload_anim
{
    and #&7f                    ; top-bit = triggered
    sta do_task_load_X+1
    lda next_buffer_HI
    sta do_task_load_A+1
    SET_TASK_FN decrunch_anim
    rts
}

; A = text block no.
.prepare_text
{
    sta do_task_load_X+1
    lda next_buffer_HI
    sta do_task_load_A+1
    SET_TASK_FN plot_text_block
    rts
}

; A = to_addr
; X = anim no.
.decrunch_anim
{
    pha
    txa:asl a:asl a:tax 
    ldy anims_table+2, X
    ; SWRAM_SELECT
    lda swram_slots_base, y
    sta &f4:sta &fe30

    ldy anims_table+1, X
    IF _DEBUG
    {
        bmi ok
        DEBUG_ERROR debug_msg_error_anim
        pla:rts
        .ok
    }
    ENDIF
    lda anims_table+0, X
    tax
    pla
    jmp decrunch_to_page_A
}

; A = anim no.
.handle_anim
{
    CHECK_TASK_NOT_RUNNING
    tax
    jsr set_all_black_palette
    txa
    bpl regular_anim

    \\ Triggered animation
    lda #LO(anims_triggered_update)
    sta do_per_frame_fn+1
    lda #HI(anims_triggered_update)
    sta do_per_frame_fn+2
    bne return                      ; always taken

    .regular_anim
    lda #LO(anims_frame_update)
    sta do_per_frame_fn+1
    lda #HI(anims_frame_update)
    sta do_per_frame_fn+2

    .return
    lda #1:sta anims_frame_delay    ; do per frame update immediately
}
\\ Fall through!
.display_next_buffer_as_mode8
{
    jsr set_mode_8
    jsr set_per_irq_do_nothing
    jmp display_next_or_prev_buffer
}

; A = fx no.
.handle_special_fx
{
    sta load_fx_no+1

    asl a:asl a:tax 
    lda special_fx_table+3, X
    IF _DEBUG
    {
        bne ok
        DEBUG_ERROR debug_msg_error_special
        rts
        .ok
    }
    ENDIF
    sta do_fx_jmp+2
    lda special_fx_table+2, X
    sta do_fx_jmp+1

    .load_fx_no
    lda #0
    .do_fx_jmp
    jmp &FFFF
}

; A = fx no.
.preload_special_fx
{
    asl a:asl a:tax 
    lda special_fx_table+1, X
    beq no_preload

    sta do_task_jmp+2
    lda special_fx_table+0, X
    sta do_task_jmp+1

    lda next_buffer_HI
    sta do_task_load_A+1
    lda display_buffer_HI
    sta do_task_load_X+1
    lda prev_buffer_HI
    sta do_task_load_Y+1
    REQUEST_TASK

    .no_preload
    rts
}

; A = code no.
.handle_screen
{
    asl a: tax
    lda screen_ctrl_table+1, X
    IF _DEBUG
    {
        bne ok
        DEBUG_ERROR debug_msg_error_special
        rts
        .ok
    }
    ENDIF
    sta do_ctrl_jmp+2
    lda screen_ctrl_table+0, X
    sta do_ctrl_jmp+1

    lda #0
    .do_ctrl_jmp
    jmp &FFFF
}
