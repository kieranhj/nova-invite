;;  -*- beebasm -*-

MACRO SELECT_MUSIC_SLOT
{
    lda &f4:pha
    lda swram_slots_base + SLOT_MUSIC
    sta &f4:sta &fe30
}
ENDMACRO

MACRO RESTORE_SLOT
{
    pla:sta &f4:sta &fe30
}
ENDMACRO

MACRO MUSIC_JUMP_INIT_TUNE
{
    SELECT_MUSIC_SLOT
    jsr music_init_tune
    RESTORE_SLOT
}
ENDMACRO

MACRO MUSIC_JUMP_VGM_UPDATE
{
    SELECT_MUSIC_SLOT
    jsr vgm_poll_player
    RESTORE_SLOT
}
ENDMACRO

MACRO MUSIC_JUMP_SN_RESET
{
    SELECT_MUSIC_SLOT
    jsr vgm_deinit_player
    RESTORE_SLOT
}
ENDMACRO

MACRO MUSIC_JUMP_SILENT
{
    SELECT_MUSIC_SLOT
	jsr music_silent
    RESTORE_SLOT
}
ENDMACRO

MACRO MUSIC_JUMP_LOUD
{
    SELECT_MUSIC_SLOT
    jsr music_loud
    RESTORE_SLOT
}
ENDMACRO
