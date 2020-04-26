;;  -*- beebasm -*-

MACRO SELECT_MUSIC_SLOT
{
    lda &f4:pha
    lda MUSIC_SLOT_ZP
    bmi no_music
    sta &f4:sta &fe30
}
ENDMACRO

MACRO RESTORE_SLOT
{
    pla:sta &f4:sta &fe30
}
ENDMACRO

.MUSIC_JUMP_INIT_TUNE
{
    SELECT_MUSIC_SLOT
    jsr music_init_tune
    .no_music
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_VGM_UPDATE
{
    SELECT_MUSIC_SLOT
    jsr vgm_update
    .no_music
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_SN_RESET
{
    SELECT_MUSIC_SLOT
    jsr sn_reset
    .no_music
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_SILENT
{
    SELECT_MUSIC_SLOT
	jsr music_silent
    .no_music
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_LOUD
{
    SELECT_MUSIC_SLOT
    jsr music_loud
    .no_music
    RESTORE_SLOT
    rts
}
