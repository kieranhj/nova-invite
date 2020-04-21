\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	SCREEN LIBRARY
\ ******************************************************************

.wait_for_vsync
{
	lda #2
	.vsync1
	bit &FE4D
	beq vsync1
;   sta &FE4D       ; ack'd in IRQ
	rts
}

.wait_frames
{
    .loop
    jsr wait_for_vsync
    dex
    bne loop
    rts
}

.set_palette
{
    stx pal_loop+1
    sty pal_loop+2

	ldx #15
	.pal_loop
	lda default_palette, X
	sta &fe21
	dex
	bpl pal_loop
	rts
}

.show_screen
	lda #&c0        ; video enable
	equb &2c		; BIT abs
.hide_screen
	lda #&f0        ; video disable
{
	ldx #8:stx &fe00:sta &fe01      ; CRTC R8
	rts
}

; Y=to page, X=number of pages
.clear_pages
{
	sty write_to+2

	ldy #0
	lda #0
	.page_loop
	.write_to
	sta &ff00, Y
	iny
	bne page_loop
	inc write_to+2
	dex
	bne page_loop

	rts
}
