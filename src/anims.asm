\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
\ ******************************************************************

.anims_ramp_table
{
    ; address of ramp, length of ramp.
    EQUW 0, 0                       ; &50 - use default for anim no.
    EQUW anims_ramp_red, 2          ; &51
    EQUW anims_ramp_green, 2        ; &52
    EQUW anims_ramp_yellow, 2       ; &53
    EQUW anims_ramp_blue, 2         ; &54
    EQUW anims_ramp_magenta, 2      ; &55
    EQUW anims_ramp_cyan, 2         ; &56
    EQUW anims_ramp_white, 2        ; &57
    EQUW anims_ramp_atom, 5         ; &58
    EQUW anims_ramp_galaxy, 5       ; &59
    EQUW anims_ramp_world, 4        ; &5A
    EQUW 0, 0                       ; &5B
    EQUW 0, 0                       ; &5C
    EQUW 0, 0                       ; &5D
    EQUW 0, 0                       ; &5E
    EQUW 0, 0                       ; &5F
}

.anims_mode_table
{
    ; mode func
    EQUW 0                          ; &70 - use default for anim no.
    EQUW anim_loop_forwards         ; &71
    EQUW anim_loop_backwards        ; &72
    EQUW 0                          ; &73
    EQUW 0                          ; &74
    EQUW 0                          ; &75
    EQUW 0                          ; &76
    EQUW 0                          ; &77
    EQUW 0                          ; &78
    EQUW 0                          ; &79
    EQUW 0                          ; &7A
    EQUW 0                          ; &7B
    EQUW 0                          ; &7C
    EQUW 0                          ; &7D
    EQUW 0                          ; &7E
    EQUW 0                          ; &7F
}

; A = ramp no.
.anims_set_ramp
{
    asl a:asl a
    tax

    lda anims_ramp_table+1, X
    IF _DEBUG
    bne ok
    brk
    .ok
    ENDIF
    sta anims_ramp_ptr+1
    lda anims_ramp_table+0, X
    sta anims_ramp_ptr

    lda anims_ramp_table+2, X
    sta anims_ramp_length

    .return
    rts
}

; A = delay
.anims_set_speed
{
    sta anims_frame_speed
    .return
    rts
}

; A = anim mode
.anims_set_mode
{
    asl a:tax
    lda anims_mode_table+1, X
    IF _DEBUG
    bne ok
    brk
    .ok
    ENDIF
    sta do_per_frame_fn+2
    lda anims_mode_table+0, X
    sta do_per_frame_fn+1

    .return
    rts
}

; A = anim no.
.anims_set_anim
{
    \\ Clear palette to all black then update once to start
    jsr set_all_black_palette
    jsr do_per_frame_fn
    
    lda anims_frame_speed
    sta anims_frame_delay
    rts
}

.anims_frame_update
{
    dec anims_frame_delay
    bne return

    jsr anim_loop_forwards
    
    lda anims_frame_speed
    sta anims_frame_delay

    .return
    rts
}

IF 0
.anim_galaxy_cycle
{
    anim_galaxy_I = local_vars+0

    ldx #0
    .loop
    txa
    clc
    adc anim_galaxy_I
    and #7
    clc
    adc #8
    asl a:asl a:asl a:asl a
    ora anim_galaxy_table, X
    sta &fe21
    inx
    cpx #5
    bcc loop
    inc anim_galaxy_I
    rts

    .anim_galaxy_table
    EQUS PAL_black,PAL_blue,PAL_red,PAL_yellow,PAL_white
}

.anim_atom_cycle
{
    anim_atom_I = local_vars+0

    ldx #0
    .loop
    txa
    clc
    adc anim_atom_I
    tay
    lda mod15_table, y
    clc
    adc #1

    asl a:asl a:asl a:asl a
    ora anim_atom_table, X
    sta &fe21
    inx
    cpx #5
    bcc loop
    inc anim_atom_I
    rts

    .anim_atom_table
    EQUS PAL_black,PAL_blue,PAL_blue,PAL_cyan,PAL_white
}

.anim_cross_cycle
{
    anim_cross_A = local_vars+0

    lda anim_cross_A
    asl a:asl a:asl a:asl a
    ora #PAL_black
    sta &fe21           ; set A to black

    ldy anim_cross_A
    lda mod15_table, y
    adc #1
    sta anim_cross_A

    asl a:asl a:asl a:asl a
    ora #PAL_green
    sta &fe21

    rts
}

.anim_world_cycle
{
    anim_world_I = local_vars+0

    ldx #0
    .loop
    txa
    clc
    adc anim_world_I
    tay
    lda mod15_table, y
    clc
    adc #1

    asl a:asl a:asl a:asl a
    ora anim_world_table, X
    sta &fe21
    inx
    cpx #4
    bcc loop
    inc anim_world_I
    rts

    .anim_world_table
    EQUS PAL_black,PAL_blue,PAL_green,PAL_cyan
}
ENDIF

.anim_loop_forwards
{
    ldy #0
    .loop
    tya
    clc
    adc anims_colour_index
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    iny
    cpy anims_ramp_length
    bcc loop

    inc anims_colour_index
    rts
    ; 1=black, 2=blue, 3=green, 4=cyan
    ; 2=black, 3=blue, 4=green, 5=cyan etc.
}

.anim_loop_backwards
{
    ldy anims_ramp_length
    .loop
    tya
    clc
    adc anims_colour_index
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    dey
    bne loop

    dec anims_colour_index
    rts

    ; 1=black, 
}

.anim_loop_ramp_hi8
{
    ldy #0
    .loop
    txa
    clc
    adc anims_colour_index
    and #7
    clc
    adc #8
    asl a:asl a:asl a:asl a
    ora (anims_ramp_ptr), Y
    sta &fe21
    iny
    cpy anims_ramp_length
    bcc loop
    inc anims_colour_index
    rts
}

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