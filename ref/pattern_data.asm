\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FX PATTERN DATA
\ ******************************************************************

tfx_cmd_end = 128
tfx_cmd_load_asset_to_screen = 129
tfx_cmd_show_screen_as_mode_4 = 130
tfx_cmd_show_screen_as_mode_8 = 131
tfx_cmd_set_beat_fn = 132
tfx_cmd_set_frame_fn = 133

MACRO LINE l
    IF l < 0
        ERROR "Cannot have negative line number."
    ENDIF
    IF l >= TRACK_PATTERN_LENGTH
        ERROR "Line number out of range."
    ENDIF
    EQUB l
ENDMACRO

MACRO BEAT b
    LINE b * TRACK_LINES_PER_BEAT
ENDMACRO

MACRO END_PATTERN
    EQUB tfx_cmd_end
ENDMACRO

MACRO LOAD_ASSET a, s
    EQUB tfx_cmd_load_asset_to_screen, a, s
ENDMACRO

MACRO SHOW_2SCREEN s
    EQUB tfx_cmd_show_screen_as_mode_4, s
ENDMACRO

MACRO SHOW_16SCREEN s
    EQUB tfx_cmd_show_screen_as_mode_8, s
ENDMACRO

MACRO SET_BEAT_FN fn_addr
    EQUB tfx_cmd_set_beat_fn
    EQUW fn_addr
ENDMACRO

MACRO SET_FRAME_FN fn_addr
    EQUB tfx_cmd_set_frame_fn
    EQUW fn_addr
ENDMACRO

.cycle_fg_colours
{
    rts
}

.pattern_1      ; BEGIN_PATTERN
{
    BEAT 0  :   LOAD_ASSET asset_big_n, 0
                SET_BEAT_FN cycle_fg_colours
    
    BEAT 1  :   SHOW_2SCREEN 0
                LOAD_ASSET asset_big_o, 1

    BEAT 2  :   SHOW_2SCREEN 1
                LOAD_ASSET asset_big_v, 0

    BEAT 3  :   SHOW_2SCREEN 0
                LOAD_ASSET asset_big_a, 1

    BEAT 4  :   SHOW_2SCREEN 1
                LOAD_ASSET asset_nova, 0

    BEAT 5  :   SHOW_2SCREEN 0
                LOAD_ASSET asset_nova_4, 1

    BEAT 6  :   SHOW_2SCREEN 1
                LOAD_ASSET asset_bs_teletext, 0

    BEAT 7  :   SHOW_2SCREEN 0
                LOAD_ASSET asset_atom, 1

    BEAT 9  :   SHOW_2SCREEN 1
                LOAD_ASSET asset_cross, 0

    BEAT 11 :   SHOW_2SCREEN 0
                LOAD_ASSET asset_galaxy, 1

    BEAT 13 :   SHOW_2SCREEN 1
                LOAD_ASSET asset_world, 0

    BEAT 15 :   SHOW_2SCREEN 0
}
END_PATTERN
