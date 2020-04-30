\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DEBUG TRACKER HEADER
\ ******************************************************************

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

.debug_msg_no       skip 1
ENDIF
