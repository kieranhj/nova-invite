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
    EQUW exo_image_nova_3           ; c105
    EQUW exo_image_bs_logo          ; c106
    EQUW exo_image_bs_logo2         ; c107
    EQUW exo_image_tmt_logo         ; c108
    EQUW exo_image_tmt_logo2        ; c109
    EQUW exo_image_nova_2020        ; c10A
    EQUW 0                          ; c10B
    EQUW 0                          ; c10C
    EQUW 0                          ; c10D
    EQUW 0                          ; c10E
    EQUW 0                          ; c10F
}

.anims_table
{
    EQUW exo_anims_shift,           6   ; c200
    EQUW exo_anims_turbluent,       6   ; c201
    EQUW exo_anims_triangle,        6   ; c202
    EQUW exo_anims_claw,            6   ; c203
    EQUW exo_anims_star,            6   ; c204
    EQUW exo_anims_circle,          6   ; c205
    EQUW exo_anims_faces,           6   ; c206
    EQUW exo_anims_square,          7   ; c207
    EQUW exo_anims_kaleidoscope,    7   ; c208
    EQUW exo_anims_sine_horizontal, 7   ; c209
    EQUW exo_anims_sine_vertical,   7   ; c20A
    EQUW 0, 0                       ; c20B
    EQUW 0, 0                       ; c20C
    EQUW 0, 0                       ; c20D
    EQUW 0, 0                       ; c20E
    EQUW exo_anims_world,           6   ; c20F
}

.special_fx_table
{
    EQUW prepare_static,        handle_static       ; c400
    EQUW prepare_quad_image,    handle_image        ; c401
    EQUW prepare_quad_anim,     handle_anim         ; c402
    EQUW 0 ,0                                       ; c403
    EQUW 0 ,0                                       ; c404
    EQUW 0 ,0                                       ; c405
    EQUW 0 ,0                                       ; c406
    EQUW 0 ,0                                       ; c407
    EQUW 0 ,0                                       ; c408
    EQUW 0 ,0                                       ; c409
    EQUW 0 ,0                                       ; c40A
    EQUW 0 ,0                                       ; c40B
    EQUW 0 ,0                                       ; c40C
    EQUW 0 ,0                                       ; c40D
    EQUW 0 ,0                                       ; c40E
    EQUW 0 ,0                                       ; c40F
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
    EQUW 0, 0                       ; c50C
    EQUW 0, 0                       ; c50D
    EQUW 0, 0                       ; c50E
    EQUW 0, 0                       ; c50F
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

