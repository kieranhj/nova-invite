\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS TABLES
\ ******************************************************************

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
    EQUW 0, 0                       ; c50B
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

.anims_ramp_black
EQUB PAL_black, PAL_black

.anims_ramp_red
EQUB PAL_black, PAL_red, PAL_black

.anims_ramp_green
EQUB PAL_black, PAL_green, PAL_black

.anims_ramp_yellow
EQUB PAL_black, PAL_yellow, PAL_black

.anims_ramp_blue
EQUB PAL_black, PAL_blue, PAL_black

.anims_ramp_magenta
EQUB PAL_black, PAL_magenta, PAL_black

.anims_ramp_cyan
EQUB PAL_black, PAL_cyan, PAL_black

.anims_ramp_white
EQUB PAL_black, PAL_white, PAL_black

.anims_ramp_galaxy
EQUB PAL_black,PAL_blue,PAL_red,PAL_yellow,PAL_white, PAL_black

.anims_ramp_atom
EQUB PAL_black,PAL_blue,PAL_blue,PAL_cyan,PAL_white, PAL_black

.anims_ramp_world
EQUB PAL_black,PAL_blue,PAL_green,PAL_cyan, PAL_black
