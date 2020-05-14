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

; A = glyph no.
; Plots at writeptr, only at character address alignment
.font_plot_glyph
{
    IF _DEBUG
    {
        cmp #FONT_MAX_GLYPHS
        bcc ok
        BRK         ; bad glyph
        .ok
    }
    ENDIF

    \\ Start of font data contains own table of offsets per gylph.
    asl a:tax
    clc
    lda font_data+0, X
    adc #LO(font_data)
    sta readptr
    lda font_data+1, X
    adc #HI(font_data)
    sta readptr+1

    lda writeptr
    sta font_store_writeptr
    lda writeptr+1
    sta font_store_writeptr+1

    \\ Super hack balls!
    ldy #0
    lda (readptr), Y
    bpl width_24

    \\ Width 16
    lda #3:sta readptr_step+1
    lda #16:sta writeptr_step+1
    lda #stop_plot-branch_plot:sta branch_plot-1        ; skip 6 bytes
    bne rle_loop

    .width_24
    lda #4:sta readptr_step+1
    lda #24:sta writeptr_step+1
    lda #keep_plot-branch_plot:sta branch_plot-1        ; skip 0 bytes

    \\ RLE font
    .rle_loop
    ldy #0
    lda (readptr), Y    ; negative means end of data.
    cmp #255
    beq done_loop
    and #&7f            ; remove top bit
    tax                 ; first byte is number of repeats.

    .line_loop
    \\ Fixed widht of 24
    ldy #1:lda (readptr), Y
    ldy #0:sta (writeptr), Y
    ldy #2:lda (readptr), Y
    ldy #8:sta (writeptr), Y
    ldy #3
    bne stop_plot
    .branch_plot
    .keep_plot
    lda (readptr), Y
    ldy #16:sta (writeptr), Y
    .stop_plot

    \\ Next line on screen
    lda writeptr
    and #7
    cmp #7
    beq next_row

    inc writeptr
    bne next_line

    .next_row
    lda writeptr
    and #&f8
    sta writeptr
    inc writeptr+1

    .next_line
    dex
    bne line_loop

    clc
    lda readptr
    .readptr_step
    adc #4
    sta readptr
    bcc no_carry
    inc readptr+1
    .no_carry
    jmp rle_loop

    .done_loop
    clc
    lda font_store_writeptr
    .writeptr_step
    adc #24
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
