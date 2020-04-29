\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DEBUG
\ ******************************************************************

IF _DEBUG
.debug_reset_writeptr
{
    lda display_buffer_HI
    IF _DEBUG_STATUS_BAR
    clc:adc #31
    ENDIF
    sta debug_writeptr+1
    lda #0
    sta debug_writeptr
    rts
}

.debug_write_hex_spc
    sec
    equb &24		; BIT zp - swallow clc
.debug_write_hex
{
    clc
    php

    pha
    lsr a:lsr a:lsr a:lsr a
    tax
    
    lda hex, X
    jsr debug_plot_char
    pla
    and #&f
    tax:lda hex, X
    jsr debug_plot_char

    plp
    bcc return

    clc
    lda debug_writeptr
    adc #8
    sta debug_writeptr
    bcc return
    inc debug_writeptr+1
	.return
    rts

    .hex
    EQUS "0123456789ABCDEF"
}

.debug_plot_char
{
    sta char_def

    IF NOT(_DEBUG_STATUS_BAR)
    lda &248
    cmp #ULA_Mode8
    beq plot_mode8
    ENDIF

    lda #10
    ldx #LO(char_def)
    ldy #HI(char_def)
    jsr osword
    
    ldy #0
    .loop
    lda char_def+1, Y
    sta (debug_writeptr), Y
    iny
    cpy #8
    bcc loop

    clc
    lda debug_writeptr
    adc #8
    sta debug_writeptr
    bcc return
    inc debug_writeptr+1
	.return
    rts

    .char_def
    skip 9

    IF NOT(_DEBUG_STATUS_BAR)
    .plot_mode8
    lda char_def
    sec
    sbc #'0'
    cmp #10
    bcc ok
    sbc #'A'-'0'-10
    .ok
    asl a:asl a:asl a:asl a
    tax

    ldy #0
    .loop8
    lda debug_font_data, X
    inx
    sta (debug_writeptr), Y
    tya:clc:adc #8:tay
    lda debug_font_data, X
    inx
    sta (debug_writeptr), Y
    tya:sec:sbc #7:tay
    cpy #8
    bcc loop8    

    clc
    lda debug_writeptr
    adc #16
    sta debug_writeptr
    bcc return8
    inc debug_writeptr+1
	.return8
    rts
    ENDIF
}

.debug_plot_string
{
    stx loop+1
    sty loop+2

    ldx #0
    .loop
    lda &ffff, X
    beq done
    stx temp_x+1
    jsr debug_plot_char
    .temp_x
    ldx #0
    inx
    bne loop
    .done
    rts
}

.debug_check_key
{
    sta ldx_addr+1
    lda #$81
    ldy #$ff
    jsr osbyte
    cpx #$ff						; C=1 if pressed
    .ldx_addr:ldx #$ff
    lda 0,x
    ror a
    sta 0,x
    and #%11000000
    cmp #%10000000
    rts
}

MACRO MODE8_PIXELS a,b,c,d
EQUB a * 14 + b * 7, c * 14 + d * 7
ENDMACRO

IF NOT(_DEBUG_STATUS_BAR)
.debug_font_data
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,3,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 0,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,0,3,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 0,0,0,0

MODE8_PIXELS 3,3,3,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,3,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 3,0,0,0
MODE8_PIXELS 0,0,0,0
ENDIF
ENDIF
