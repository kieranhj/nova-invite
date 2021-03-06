\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DEBUG TRACKER HEADER
\ ******************************************************************

;SLOT_DEBUG = SLOT_BANK2
BANK_ANDY = &80

debug_msg_play = 0
debug_msg_paused = 1
debug_msg_step_frame = 2
debug_msg_step_line = 3
debug_msg_run_to_next = 4
debug_msg_error_task = 5
debug_msg_error_ramp = 6
debug_msg_error_mode = 7
debug_msg_error_parse = 8
debug_msg_error_image = 9
debug_msg_error_anim = 10
debug_msg_error_special = 11
debug_msg_error_text = 12

MACRO DEBUG_ERROR e
IF _DEBUG_STATUS_BAR
{
    lda #e:sta debug_msg_no
    lda #1:sta debug_paused
}
ELSE
    BRK             ; boom!
ENDIF
ENDMACRO

MACRO SELECT_DEBUG_SLOT
{
    lda &f4:pha
    lda #BANK_ANDY      ;swram_slots_base + SLOT_DEBUG
    sta &f4:sta &fe30
}
ENDMACRO

MACRO DEBUG_do_pause_controls
{
    SELECT_DEBUG_SLOT
    jsr do_pause_controls
    RESTORE_SLOT
}
ENDMACRO

MACRO DEBUG_show_tracker_info
{
    SELECT_DEBUG_SLOT
    jsr debug_show_tracker_info
    RESTORE_SLOT
}
ENDMACRO

MACRO DEBUG_highlight_status_bar
{
    SELECT_DEBUG_SLOT
    jsr debug_highlight_status_bar
    RESTORE_SLOT
}
ENDMACRO

IF _DEBUG
.debug_writeptr     skip 2
.debug_paused       skip 1
.debug_step         skip 1
.debug_step_mode    skip 1
.pause_pattern      skip 1
.pause_line         skip 1

.pause_key_debounce     skip 1
.step_frame_debounce    skip 1
.step_line_debounce     skip 1
.next_pattern_debounce  skip 1
.restart_debounce       skip 1
.display_key_debounce   skip 1

.debug_msg_no       skip 1
.debug_show_status  skip 1

.char_def           skip 9
ENDIF
