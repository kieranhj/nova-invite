\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FONT PLOTTING
\ ******************************************************************

FONT_MAX_GLYPHS = 59
FONT_GLYPH_WIDTH_BYTES = 2
FONT_GLYPH_HEIGHT = 16
FONT_GLYPH_SIZE = FONT_GLYPH_WIDTH_BYTES * FONT_GLYPH_HEIGHT

; A = ASCII
; Plots at writeptr, only at character address alignment
.font_plot_glyph
{
    sta readptr
    IF _DEBUG
    {
        cmp #FONT_MAX_GLYPHS
        bcc ok
        BRK         ; bad glyph
        .ok
    }
    ENDIF

    lda #0
    sta readptr+1
    
    \\ Multiply by 32 - could be a 120 byte table obvs
    clc
    rol readptr:rol readptr+1
    rol readptr:rol readptr+1
    rol readptr:rol readptr+1
    rol readptr:rol readptr+1
    rol readptr:rol readptr+1

    clc
    lda readptr
    adc #LO(font_data)
    sta readptr
    lda readptr+1
    adc #HI(font_data)
    sta readptr+1

    lda writeptr
    sta temp
    lda writeptr+1
    sta temp+1

    ldx #FONT_GLYPH_HEIGHT
    .line_loop
    ldy #0
    lda (readptr), Y
    sta (writeptr), Y
    iny
    lda (readptr), Y
    ldy #8
    sta (writeptr), Y

    clc
    lda readptr
    adc #2
    sta readptr
    bcc no_carry
    inc readptr+1
    .no_carry

    dex
    beq done_loop

    lda writeptr
    and #7
    cmp #7
    beq next_row

    inc writeptr
    bne line_loop

    .next_row
    lda writeptr
    and #&f8
    sta writeptr
    inc writeptr+1
    bne line_loop
  
    .done_loop
    clc
    lda temp
    adc #16
    sta writeptr
    lda temp+1
    adc #0
    sta writeptr+1
    rts
}

; A = next buffer
; X = text block no.
.plot_text_block
{
    sta temp+3                  ; screen base
    sta writeptr+1
    lda #0
    sta writeptr

    SWRAM_SELECT SLOT_MUSIC     ; font data stored here.

    ldy #0
    .loop
    sty temp+2          ; 0,1 used to store writeptr above

    lda text_block_0, y
    beq done_loop
    cmp #32
    bcs is_ascii
    
    \\ Control codes
    cmp #12             ; CLS
    bne not_cls

    ldy temp+3
    ldx #HI(SCREEN_SIZE_BYTES)
    jsr clear_pages
    beq next_char

    .not_cls
    cmp #31
    bne not_vdu31

    \\ Set cursor
    iny
    lda text_block_0, Y
    asl a:asl a:asl a
    sta writeptr
    iny
    lda text_block_0, Y
    clc
    adc temp+3          ; screen base
    sta writeptr+1
    sty temp+2
    bne next_char

    .is_ascii
    ; C=1
    sbc #32
    jsr font_plot_glyph

    .not_vdu31
    .next_char
    ldy temp+2
    iny
    bne loop
    .done_loop

    rts
}

.text_block_0
EQUS 12,31,5,15,"HELLO WORLD",0
