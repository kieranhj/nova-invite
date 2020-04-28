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
    EQUW do_nothing, &FF            ; c700
    EQUW anim_loop_forwards, &FF    ; c701
    EQUW anim_loop_backwards, &FF   ; c702
    EQUW anim_oneshot_forwards, 0   ; c703
    EQUW anim_oneshot_backwards, 0  ; c704
    EQUW anim_ping_pong, &FF        ; c705
    EQUW anim_random, &FF           ; c706
    EQUW 0, 0                       ; c707
    EQUW 0, 0                       ; c708
    EQUW 0, 0                       ; c709
    EQUW 0, 0                       ; c70A
    EQUW 0, 0                       ; c70B
    EQUW 0, 0                       ; c70C
    EQUW 0, 0                       ; c70D
    EQUW 0, 0                       ; c70E
    EQUW 0, 0                       ; c70F
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
