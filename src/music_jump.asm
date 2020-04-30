;;  -*- beebasm -*-

.MUSIC_JUMP_INIT_TUNE
{
    SELECT_MUSIC_SLOT
    jsr music_init_tune
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_VGM_UPDATE
{
    SELECT_MUSIC_SLOT
    jsr vgm_update
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_SN_RESET
{
    SELECT_MUSIC_SLOT
    jsr sn_reset
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_SILENT
{
    SELECT_MUSIC_SLOT
	jsr music_silent
    RESTORE_SLOT
    rts
}

.MUSIC_JUMP_LOUD
{
    SELECT_MUSIC_SLOT
    jsr music_loud
    RESTORE_SLOT
    rts
}
