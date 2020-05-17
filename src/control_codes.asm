\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ASSET TABLES
\ ******************************************************************

.screen_ctrl_table
{
    EQUW hide_screen                ; c000
    EQUW show_screen                ; c001
    EQUW swap_to_prev_screen_image  ; c002
    EQUW swap_to_prev_screen_anim   ; c003
    EQUW 0                          ; c004
    EQUW 0                          ; c005
    EQUW 0                          ; c006
    EQUW 0                          ; c007
    EQUW 0                          ; c008
    EQUW 0                          ; c009
    EQUW 0                          ; c00A
    EQUW 0                          ; c00B
    EQUW 0                          ; c00C
    EQUW 0                          ; c00D
    EQUW 0                          ; c00E
    EQUW 0                          ; c00F
}

.image_table
{
    EQUW exo_image_big_n            ; c100
    EQUW exo_image_big_o            ; c101
    EQUW exo_image_big_v            ; c102
    EQUW exo_image_big_a            ; c103
    EQUW exo_image_nova             ; c104
    EQUW exo_image_nova_2020        ; c105
    EQUW 0                          ; c106
    EQUW exo_image_bs_logo2         ; c107
    EQUW exo_image_tmt_logo         ; c108
    EQUW 0                          ; c109
    EQUW exo_slide_dates            ; c10A
    EQUW exo_slide_chips            ; c10B
    EQUW exo_slide_patarty          ; c10C
    EQUW exo_image_bbc_owl          ; c10D
    EQUW 0                          ; c10E
    EQUW 0                          ; c10F
}

.anims_table
{
    EQUW 0,                         0   ; c200
    EQUW 0,                         0   ; c201
    EQUW exo_anims_triangle,        SLOT_BANK1   ; c202
    EQUW 0,                         0   ; c203
    EQUW exo_anims_star,            SLOT_BANK1   ; c204
    EQUW exo_anims_circle,          SLOT_BANK1   ; c205
    EQUW exo_anims_faces,           SLOT_BANK1   ; c206
    EQUW exo_anims_square,          SLOT_BANK1   ; c207
    EQUW exo_anims_kaleidoscope,    SLOT_BANK1   ; c208
    EQUW 0,                         0   ; c209
    EQUW exo_anims_burst,           SLOT_BANK2   ; c20A
    EQUW exo_anims_rotor,           SLOT_BANK2   ; c20B
    EQUW exo_anims_swirl,           SLOT_BANK2   ; c20C
    EQUW exo_anims_tunnel,          SLOT_BANK2   ; c20D
    EQUW exo_anims_particl,         SLOT_BANK2   ; c20E
    EQUW 0,                         0   ; c20F
}

.special_fx_table
{
    EQUW prepare_static,        handle_static       ; c400
    EQUW prepare_quad_image,    handle_image        ; c401
    EQUW prepare_quad_anim,     display_next_buffer_as_mode8         ; c402
    EQUW prepare_hbars,         handle_copper_bars  ; c403
    EQUW prepare_dbars,         handle_copper_bars  ; c404
    EQUW prepare_vubars,        handle_vubars       ; c405
    EQUW 0,                     set_vubars_colour   ; c406
    EQUW 0,                     set_vubars_colour   ; c407
    EQUW 0,                     set_vubars_colour   ; c408
    EQUW 0,                     set_vubars_colour   ; c409
    EQUW 0,                     set_small_bars_colour   ; c40A
    EQUW 0,                     set_small_bars_colour   ; c40B
    EQUW 0,                     set_small_bars_colour   ; c40C
    EQUW 0,                     set_small_bars_colour   ; c40D
    EQUW 0,                     set_large_bars_colour   ; c40E
    EQUW 0,                     set_large_bars_colour   ; c40F
    EQUW 0,                     set_large_bars_colour   ; c410
    EQUW 0,                     set_large_bars_colour   ; c411
}

.anims_ramp_table
{
    ; address of ramp, length of ramp
    EQUW anims_ramp_black, 1        ; c500
    EQUW anims_ramp_red, 2          ; c501
    EQUW anims_ramp_green, 2        ; c502
    EQUW anims_ramp_yellow, 2       ; c503
    EQUW anims_ramp_blue, 2         ; c504
    EQUW anims_ramp_magenta, 2      ; c505
    EQUW anims_ramp_cyan, 2         ; c506
    EQUW anims_ramp_white, 2        ; c507
    EQUW anims_ramp_atom, 5         ; c508
    EQUW anims_ramp_galaxy, 5       ; c509
    EQUW anims_ramp_world, 4        ; c50A
    EQUW anims_ramp_static, 8       ; c50B
    EQUW anims_ramp_burst, 4        ; c50C
    EQUW anims_ramp_cool, 4         ; c50D
    EQUW anims_ramp_swirl, 4        ; c50E
    EQUW 0, 0   ; c50F
}

.anims_mode_table
{
    ; mode func, optional start value for index
    EQUW do_nothing, &FF            ; c60y
    EQUW anim_loop_forwards, &FF    ; c61y
    EQUW anim_loop_backwards, &FF   ; c62y
    EQUW anim_oneshot_forwards, 0   ; c63y
    EQUW anim_oneshot_backwards, 0  ; c64y
    EQUW anim_ping_pong, &FF        ; c65y
    EQUW anim_random, &FF           ; c66y
    EQUW 0, 0                       ; c67y
    EQUW 0, 0                       ; c68y
    EQUW 0, 0                       ; c69y
    EQUW 0, 0                       ; c6Ay
    EQUW 0, 0                       ; c6By
    EQUW 0, 0                       ; c6Cy
    EQUW 0, 0                       ; c6Dy
    EQUW 0, 0                       ; c6Ey
    EQUW 0, 0                       ; c6Fy
}

