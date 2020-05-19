\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DEBUG FOR 
\ ******************************************************************

MACRO DEBUG_MESSAGE m
IF _DEBUG_STATUS_BAR
{
    LDA #m: STA debug_msg_no
}
ELSE
ENDIF
ENDMACRO

IF _DEBUG_STATUS_BAR
.debug_message_table
{
    EQUW debug_message_0
    EQUW debug_message_1
    EQUW debug_message_2
    EQUW debug_message_3
    EQUW debug_message_4
    EQUW debug_message_5
    EQUW debug_message_6
    EQUW debug_message_7
    EQUW debug_message_8
    EQUW debug_message_9
    EQUW debug_message_10
    EQUW debug_message_11
    EQUW debug_message_12
}

.debug_message_0 EQUS "Play", 0
.debug_message_1 EQUS "Paused", 0
.debug_message_2 EQUS "Step frame", 0
.debug_message_3 EQUS "Step line ", 0
.debug_message_4 EQUS "Run to next", 0
.debug_message_5 EQUS "ERROR:Task running", 0
.debug_message_6 EQUS "ERROR:Unknown ramp", 0
.debug_message_7 EQUS "ERROR:Unknown mode", 0
.debug_message_8 EQUS "ERROR:Parse failed", 0
.debug_message_9 EQUS "ERROR:Unknown image", 0
.debug_message_10 EQUS "ERROR:Unknown anim", 0
.debug_message_11 EQUS "ERROR:Unknown spfx", 0
.debug_message_12 EQUS "ERROR:Unknown text", 0
ENDIF

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
    JSR MUSIC_JUMP_SN_RESET

    \\ Toggle pause
    lda debug_paused:eor #1:sta debug_paused
    sta debug_msg_no

    .not_pressed_pause
    lda #display_key_debounce
    ldx #KEY_DISPLAY_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_display

    \\ Toggle display
    lda debug_show_status:eor #1:sta debug_show_status

    .not_pressed_display
    lda debug_paused
    beq exit_and_update

    \\ Check for step frame
    lda #step_frame_debounce
    ldx #KEY_STEP_FRAME_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_step_frame
    DEBUG_MESSAGE debug_msg_step_frame

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
    DEBUG_MESSAGE debug_msg_step_line
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
    DEBUG_MESSAGE debug_msg_run_to_next
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
IF NOT(_DEBUG_STATUS_BAR)
{
    \\ XXyy CCdd
    jsr debug_reset_writeptr
    lda events_pattern
    jsr debug_write_hex
    lda events_line
    jsr debug_write_hex_spc
    lda events_code
    jsr debug_write_hex
    lda events_data
    jsr debug_write_hex_spc

    \\ XXyy CCdd
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
ELSE
{
    lda debug_show_status
    ora debug_paused
    beq return

    jsr debug_reset_writeptr

    \\ PP:LL cCdd t>Status message
    lda debug_msg_no
    cmp #debug_msg_error_image
    bne not_image_error

    .is_preload_error
    \\ Show preload vars.
    lda preload_pattern
    jsr debug_write_hex
    lda #':':jsr debug_write_char
    lda preload_line
    jsr debug_write_hex_spc
    lda #'p':jsr debug_write_char
    lda preload_code
    jsr debug_write_hex1
    lda preload_data
    jsr debug_write_hex_spc
    jmp continue

    .not_image_error
    cmp #debug_msg_error_anim
    beq is_preload_error

    \\ Show events vars.
    lda events_pattern
    jsr debug_write_hex
    lda #':':jsr debug_write_char
    lda events_line
    jsr debug_write_hex_spc
    lda #'c':jsr debug_write_char
    lda events_code
    jsr debug_write_hex1
    lda events_data
    jsr debug_write_hex_spc

    .continue
    lda task_request
    clc:adc #'0'
    jsr debug_write_char
    lda #'>'
    jsr debug_write_char

    lda debug_msg_no
    asl a:tax
    ldy debug_message_table+1, X
    lda debug_message_table+0, X
    tax
    jsr debug_write_string

    ldy #0
    ldx debug_writeptr
    lda #0
    .loop
    sta (debug_writeptr), Y
    iny
    inx
    bne loop

    .return
    rts
}
ENDIF

IF _DEBUG_STATUS_BAR
.debug_highlight_status_bar
{
    lda debug_show_status
    ora debug_paused
    beq no_mode_change

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

    .no_mode_change

    \\ Wait ~8 scanlines
    ldx #114
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
