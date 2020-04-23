\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
\ ******************************************************************

.anim_fn_table
{
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW anim_galaxy_init,  anim_atom_cycle
    EQUW anim_galaxy_init,  anim_cross_cycle
    EQUW anim_galaxy_init,  anim_galaxy_cycle
    EQUW anim_galaxy_init,  anim_world_cycle
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
    EQUW 0,                 do_nothing
}

; A = anim no.
.anims_set_anim
{
    asl a:asl a
    tax

    \\ Call init fn (if any).
    lda anim_fn_table+1, X
    beq no_init
    sta jmp_to_init+2
    lda anim_fn_table+0, X
    sta jmp_to_init+1
    .jmp_to_init
    jsr &ffff

    \\ Install per-frame fn.
    .no_init
    lda anim_fn_table+2, X
    sta do_per_frame_fn+1
    sta advance_loop+1
    lda anim_fn_table+3, X
    sta do_per_frame_fn+2
    sta advance_loop+2

    ldy #15
    .advance_loop
    jsr &ffff
    dey 
    bpl advance_loop

    rts
}

anim_galaxy_I = local_vars+0

.anim_galaxy_init
{
    lda #0  ; actual RND
    sta anim_galaxy_I
    rts
}

.anim_galaxy_cycle
{
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
    cmp #15
    bcc ok
    sbc #15
    .ok
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

    lda anim_cross_A
    cmp #15
    bcc ok
    sbc #15
    .ok
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
    cmp #15
    bcc ok
    sbc #15
    .ok
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
