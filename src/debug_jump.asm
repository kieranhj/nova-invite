;;  -*- beebasm -*-

IF _DEBUG

MACRO SELECT_DEBUG_SLOT
{
    lda &f4:pha
    lda MUSIC_SLOT_ZP
    sta &f4:sta &fe30
}
ENDMACRO

.DEBUG_do_pause_controls
{
    SELECT_DEBUG_SLOT
    jsr do_pause_controls
    RESTORE_SLOT
    rts
}

.DEBUG_show_tracker_info
{
    SELECT_DEBUG_SLOT
    jsr debug_show_tracker_info
    RESTORE_SLOT
    rts
}

.DEBUG_highlight_status_bar
{
    SELECT_DEBUG_SLOT
    jsr debug_highlight_status_bar
    RESTORE_SLOT
    rts
}

ENDIF
