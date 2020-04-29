\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DEBUG FOR 
\ ******************************************************************

IF _DEBUG
.do_pause_controls
{
    lda debug_step_mode
    beq not_stepping

    cmp #1:bne step_to_pattern

    \\ Step to line
    lda pause_line
    cmp events_line
    beq exit_and_update
    bne done_stepping

    .step_to_pattern
    lda pause_pattern
    cmp events_pattern
    beq exit_and_update

    \\ Done stepping
    .done_stepping
    lda #0:sta debug_step_mode

    .not_stepping
    lda #pause_key_debounce
    ldx #KEY_PAUSE_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_pause

    \\ Entering pause
    jsr MUSIC_JUMP_SN_RESET

    \\ Toggle pause
    lda debug_paused:eor #1:sta debug_paused

    .not_pressed_pause
    lda debug_paused
    beq exit_and_update

    \\ Check for step frame
    lda #step_frame_debounce
    ldx #KEY_STEP_FRAME_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_step_frame

    .exit_and_update
    clc
    rts

    .not_pressed_step_frame
    \\ Check for step line
    lda #step_line_debounce
    ldx #KEY_STEP_LINE_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_step_line

    lda events_line
    sta pause_line
    lda #1:sta debug_step_mode
    bne exit_and_update

    .not_pressed_step_line
    \\ Check for step pattern
    lda #next_pattern_debounce
    ldx #KEY_NEXT_PATTERN_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_next_pattern

    lda events_pattern
    sta pause_pattern
    lda #2:sta debug_step_mode
    bne exit_and_update

    .not_pressed_next_pattern
    \\ Check for restart
    lda #restart_debounce
    ldx #KEY_RESTART_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_restart

    \\ Nuke!
    lda #LO(restart)
    sta do_task_jmp+1
    lda #HI(restart)
    sta do_task_jmp+2
    lda #1
    sta do_task_load_A+1
    inc task_request

    .not_pressed_restart
    lda #0:sta debug_step
    sec
    rts
}

.debug_show_tracker_info
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

    IF _DEBUG_SHOW_PRELOAD    
    lda preload_pattern
    jsr debug_write_hex
    lda preload_line
    jsr debug_write_hex_spc
    lda preload_code
    jsr debug_write_hex
    lda preload_data
    jsr debug_write_hex_spc
    ENDIF

    rts
}

IF _DEBUG_STATUS_BAR
.debug_highlight_status_bar
{
    lda #ULA_Mode4:sta &fe20        ; force MODE 4

    \\ Force palette to status bar colours for visibility.
    lda #PAL_white
    .bg_loop
    sta &fe21
    clc:adc #&10
    bpl bg_loop
    eor #7
    .fg_loop
    sta &fe21
    clc:adc #&10
    bcc fg_loop

    \\ Wait ~7 scanlines = ~900 cycles
    ldx #100
    .wait_loop
    bit &1234       ; 4c
    dex             ; 2c
    bne wait_loop   ; 3c

    \\ Restore mode and palette to what it was previously!
    lda &248:sta &fe20

    ldx #15
    .pal_loop
    lda &00, X
    sta &fe21
    dex
    bpl pal_loop

    rts
}
ENDIF

ENDIF
