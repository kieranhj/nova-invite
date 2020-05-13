\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FONT PLOTTING
\ ******************************************************************

FONT_MAX_GLYPHS = 59
FONT_GLYPH_WIDTH_BYTES = 2
FONT_GLYPH_HEIGHT = 16
FONT_GLYPH_SIZE = FONT_GLYPH_WIDTH_BYTES * FONT_GLYPH_HEIGHT

font_store_writeptr = temp+0
font_text_index = temp+2
font_scr_base = temp+3
font_textptr = temp+4

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
    sta font_store_writeptr
    lda writeptr+1
    sta font_store_writeptr+1

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
    lda font_store_writeptr
    adc #16
    sta writeptr
    lda font_store_writeptr+1
    adc #0
    sta writeptr+1
    rts
}

; A = next buffer
; X = text block no.
.plot_text_block
{
    sta font_scr_base
    sta writeptr+1
    lda #0
    sta writeptr

    \\ Page in font and text data (safe as this is from main thread)
    SWRAM_SELECT SLOT_MUSIC

    txa:asl a:tax 
    lda text_block_table+1, X
    IF _DEBUG
    {
        bmi ok
        DEBUG_ERROR debug_msg_error_text
        rts
        .ok
    }
    ENDIF
    sta font_textptr+1
    lda text_block_table+0, X
    sta font_textptr

    ldy #0
    .loop
    sty font_text_index

    lda (font_textptr), y
    beq done_loop
    cmp #32
    bcs is_ascii
    
    \\ Control codes
    cmp #12             ; CLS
    bne not_cls

    ldy font_scr_base
    ldx #HI(SCREEN_SIZE_BYTES)
    jsr clear_pages
    beq next_char

    .not_cls
    cmp #31
    bne not_vdu31

    \\ Set cursor
    iny
    lda (font_textptr), Y
    asl a:asl a:asl a
    sta writeptr
    iny
    lda (font_textptr), Y
    clc
    adc font_scr_base
    sta writeptr+1
    sty font_text_index
    bne next_char

    .is_ascii
    ; C=1
    sbc #32
    jsr font_plot_glyph

    .not_vdu31
    .next_char
    ldy font_text_index
    iny
    bne loop
    .done_loop

    rts
}
