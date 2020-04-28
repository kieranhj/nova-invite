\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
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
    EQUW 0, 0                       ; c705
    EQUW 0, 0                       ; c706
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
    rts
}

; A = anim mode
.anims_set_mode
{
    asl a:asl a:tax
    lda anims_mode_table+1, X
    IF _DEBUG
    bne ok
    brk
    .ok
    ENDIF
    sta anim_frame_update_fn+2
    lda anims_mode_table+0, X
    sta anim_frame_update_fn+1

    ; optional start value for index
    lda anims_mode_table+2, X
    bmi return
    sta anims_colour_index

    .return
    rts
}

.anims_frame_update
{
    dec anims_frame_delay
    bne return

    .^anim_frame_update_fn
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

    ldx anims_colour_index
    inx
    cpx #MOD15_MAX
    bcc ok
    ldx #0
    .ok
    stx anims_colour_index
    
    rts
}

.anim_loop_backwards
{
    ldx anims_colour_index
    dex
    cpx #255
    bne ok
    ldx #MOD15_MAX-1
    .ok
    stx anims_colour_index

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

    rts
}

.anim_oneshot_forwards
{
    lda anims_colour_index
    bmi return

    ldy anims_ramp_length
    dey

    ldx anims_colour_index  ; go from 0->14 + ramp_length 
    .loop
    cpx #15
    bcs off_end

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21
    .off_end

    dey
    bmi done_loop
    dex
    bpl loop
    .done_loop
    inc anims_colour_index

    ; stop when last ramp reaches last colour.
    cpx #15
    bne return

    lda #128:sta anims_colour_index
   
    .return
    rts
}

.anim_oneshot_backwards
{
    lda anims_colour_index
    bmi return

    ldy anims_ramp_length
    dey

    ldx anims_colour_index
    .loop
    cpx #15
    bcs off_end

    \\ Flip the colour index to 14-x
    stx temp_x+1
    sec
    lda #14
    sbc temp_x+1
    tax

    lda mod15_plus1_asl4_table, X
    ora (anims_ramp_ptr), Y
    sta &fe21

    .temp_x
    ldx #0

    .off_end

    dey
    bmi done_loop
    dex
    bpl loop
    .done_loop
    inc anims_colour_index

    ; stop when last ramp reaches last colour.
    cpx #15
    bne return

    lda #128:sta anims_colour_index
   
    .return
    rts
}

IF 0
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
ENDIF

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