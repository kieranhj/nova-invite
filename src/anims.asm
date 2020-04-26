\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ANIMS MODULE
\ ******************************************************************

.anims_defaults_for_anim 
{
; default ramp number, default speed - (default mode)
    EQUB 8, 2                          ; atom
    EQUB 2, 1                          ; cross
    EQUB 9, 4                          ; galaxy
    EQUB 10, 1                         ; world
    EQUB 4, 3                          ; shift
    EQUB 8, 3                          ; turbulent
    EQUB 10, 5                         ; triangle
    EQUB 5, 8                          ; claw
    EQUB 0, 0                          ; &28
    EQUB 0, 0                          ; &29
    EQUB 0, 0                          ; &2A
    EQUB 0, 0                          ; &2B
    EQUB 0, 0                          ; &2C
    EQUB 0, 0                          ; &2D
    EQUB 0, 0                          ; &2E
    EQUB 0, 0                          ; &2F
}

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

; A = ramp no.
.anims_set_ramp
{
    sta anims_ramp_load
    beq return

    asl a:asl a
    tax

    lda anims_ramp_table+1, X
    bne ok
    brk
    .ok
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
    sta anims_speed_load
    beq return
    sta anims_frame_speed
    .return
    rts
}

; A = anim no.
.anims_set_anim
{
    asl a:tax

    lda anims_speed_load
    bne speed_already_set
    lda anims_defaults_for_anim+1, X
    .speed_already_set
    jsr anims_set_speed   ; preserves X

    lda anims_ramp_load
    bne ramp_already_set

    lda anims_defaults_for_anim+0, X
    .ramp_already_set
    jsr anims_set_ramp      ; trashes X

    lda #0
    sta anims_ramp_load
    sta anims_speed_load

IF 0
    lda #LO(anim_loop_ramp_15)
    sta do_per_frame_fn+1
    sta advance_loop+1
    lda #HI(anim_loop_ramp_15)
    sta do_per_frame_fn+2
    sta advance_loop+2

    lda #0      ; should be RND
    sta anims_colour_index

    lda #16
    sta loop_count
    .advance_loop
    jsr &ffff
    dec loop_count
    bne advance_loop
ELSE

    jsr set_all_black_palette
    jsr anim_loop_ramp_15
    
    lda anims_frame_speed
    sta anims_frame_delay

    lda #LO(anims_frame_update)
    sta do_per_frame_fn+1
    lda #HI(anims_frame_update)
    sta do_per_frame_fn+2

ENDIF
    rts

    .loop_count equb 0
}

.anims_frame_update
{
    dec anims_frame_delay
    bne return

    jsr anim_loop_ramp_15
    
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

.anim_loop_ramp_15
{
    ldy #0
    .loop
    tya
    clc
    adc anims_colour_index
    tax
    lda mod15_table, X
    clc
    adc #1

    asl a:asl a:asl a:asl a
    ora (anims_ramp_ptr), Y
    sta &fe21

    iny
    cpy anims_ramp_length
    bcc loop

    inc anims_colour_index
    rts
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
EQUB PAL_black, PAL_red

.anims_ramp_green
EQUB PAL_black, PAL_green

.anims_ramp_yellow
EQUB PAL_black, PAL_yellow

.anims_ramp_blue
EQUB PAL_black, PAL_blue

.anims_ramp_magenta
EQUB PAL_black, PAL_magenta

.anims_ramp_cyan
EQUB PAL_black, PAL_cyan

.anims_ramp_white
EQUB PAL_black, PAL_white

.anims_ramp_galaxy
EQUB PAL_black,PAL_blue,PAL_red,PAL_yellow,PAL_white

.anims_ramp_atom
EQUB PAL_black,PAL_blue,PAL_blue,PAL_cyan,PAL_white

.anims_ramp_world
EQUB PAL_black,PAL_blue,PAL_green,PAL_cyan
