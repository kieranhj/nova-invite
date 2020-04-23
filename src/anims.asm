\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
\ ******************************************************************

.anim_fn_table
{
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW anim_galaxy_init, anim_galaxy_cycle
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
    EQUW 0, do_nothing
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
    lda anim_fn_table+3, X
    sta do_per_frame_fn+2

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

.set_mode8_default_palette
{
    ldx #LO(mode8_default_palette)
    ldy #HI(mode8_default_palette)
    jmp set_palette
}