\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	STNICC BEEB INTRO
\ ******************************************************************

_DEBUG = TRUE
_DEBUG_RASTERS = TRUE

INCLUDE "src/zp.h.asm"
INCLUDE "src/music.h.asm"

TRACK_SPEED = 3
TRACK_PATTERN_LENGTH = 128
TRACK_LINES_PER_BEAT = 8

\ ******************************************************************
\ *	OS defines
\ ******************************************************************

osfile = &FFDD
oswrch = &FFEE
osasci = &FFE3
osbyte = &FFF4
osword = &FFF1
osfind = &FFCE
osgbpb = &FFD1
oscli  = &FFF7
osargs = &FFDA

IRQ1V = &204

\\ Palette values for ULA
PAL_black	= (0 EOR 7)
PAL_blue	= (4 EOR 7)
PAL_red		= (1 EOR 7)
PAL_magenta = (5 EOR 7)
PAL_green	= (2 EOR 7)
PAL_cyan	= (6 EOR 7)
PAL_yellow	= (3 EOR 7)
PAL_white	= (7 EOR 7)

ULA_Mode1   = &D8
ULA_Mode4   = &88

\ ******************************************************************
\ *	MACROS
\ ******************************************************************

MACRO MODE5_PIXELS a,b,c,d
    EQUB (a AND 2) * &40 OR (a AND 1) * &08 OR (b AND 2) * &20 OR (b AND 1) * &04 OR (c AND 2) * &10 OR (c AND 1) * &02 OR (d AND 2) * &08 OR (d AND 1) * &01
ENDMACRO

MACRO PAGE_ALIGN
H%=P%
ALIGN &100
PRINT "Lost ", P%-H%, "bytes"
ENDMACRO

MACRO PAGE_ALIGN_FOR_SIZE size
IF HI(P%+size) <> HI(P%)
	PAGE_ALIGN
ENDIF
ENDMACRO

MACRO CHECK_SAME_PAGE_AS base
IF HI(P%-1) <> HI(base)
PRINT "WARNING! Table or branch base address",~base, "may cross page boundary at",~P%
ENDIF
ENDMACRO

MACRO SET_BGCOL c
IF _DEBUG_RASTERS
{
    LDA #&00+c:STA &FE21
    LDA #&10+c:STA &FE21
    LDA #&20+c:STA &FE21
    LDA #&30+c:STA &FE21
    LDA #&40+c:STA &FE21
    LDA #&50+c:STA &FE21
    LDA #&60+c:STA &FE21
    LDA #&70+c:STA &FE21
}
ENDIF
ENDMACRO

MACRO SWRAM_BANK b
{
    LDA #b:STA &F4:STA &FE30
}
ENDMACRO

\ ******************************************************************
\ *	GLOBAL constants
\ ******************************************************************

; SCREEN constants
SCREEN_WIDTH_PIXELS = 256
SCREEN_HEIGHT_PIXELS = 256
SCREEN_ROW_BYTES = SCREEN_WIDTH_PIXELS * 8 / 8
SCREEN_SIZE_BYTES = (SCREEN_WIDTH_PIXELS * SCREEN_HEIGHT_PIXELS) / 4

screen1_addr = &6000
screen2_addr = &4000
screen3_addr = &2000

; Exact time for a 50Hz frame less latch load time
FramePeriod = 312*64-2

; This is when we trigger the next frame draw during the frame
; Essentially how much time we give the main loop to stream the next track
TimerValue = (40)*64 - 2*64

\ ******************************************************************
\ *	ZERO PAGE
\ ******************************************************************

ORG &00
GUARD zp_top

.zp_start

INCLUDE "lib/exo.h.asm"

.writeptr           skip 2
.vsync_count        skip 1
.music_enabled      skip 1
.music_lock         skip 1

.screen_buffer_HI
.display_buffer_HI  skip 1
.next_buffer_HI     skip 1
.prev_buffer_HI     skip 1

.exo_no             skip 1

.task_request       skip 1

INCLUDE "src/fx_tracker.h.asm"
INCLUDE "src/assets.h.asm"

.zp_end

\ ******************************************************************
\ *	BSS DATA IN LOWER RAM
\ ******************************************************************

\ ******************************************************************
\ *	CODE START
\ ******************************************************************

ORG &1100
GUARD screen3_addr

.start
.main_start

\ ******************************************************************
\ *	Code entry
\ ******************************************************************

.main
{
    \\ Init stack
    ldx #&ff:txs

    \\ Init ZP
    lda #0
    ldx #0
    .zp_loop
    sta &00, x
    inx
    cpx #zp_top
    bne zp_loop

    \\ Consts for now
    lda #4:sta MUSIC_SLOT_ZP

    \\ Load music into SWRAM (if available)
    {
        lda MUSIC_SLOT_ZP
        bmi no_music
        sta &f4:sta &fe30
        ldx #LO(music_filename)
        ldy #HI(music_filename)
        lda #HI(&8000)
        jsr disksys_load_file

        \\ Initialise music
        jsr MUSIC_JUMP_INIT_TUNE
        .no_music
    }

    \\ Load Bank0
    {
        SWRAM_BANK 5
        ldx #LO(bank0_filename)
        ldy #HI(bank0_filename)
        lda #HI(&8000)
        jsr disksys_load_file
    }

    \\ Set MODE w/out using OS.
    jsr wait_for_vsync

	\\ Set ULA register
	lda #ULA_Mode4
	sta &248			; OS copy
	sta &fe20

	\\ Set CRTC registers
	ldx #0
	.crtc_loop
	stx &fe00
	lda mode4_crtc_regs, X
	sta &fe01
	inx
	cpx #14
	bcc crtc_loop

    \\ Set palette
    ldx #LO(default_palette)
    ldy #HI(default_palette)
	jsr set_palette

    \\ Clear screens
    ldy #HI(screen3_addr)
    ldx #HI(&8000 - screen3_addr)
    jsr clear_pages

    \\ Init system
    lda #HI(screen1_addr)
    sta display_buffer_HI
    lda #HI(screen2_addr)
    sta next_buffer_HI
    lda #HI(screen3_addr)
    sta prev_buffer_HI

    jsr events_init

	\\ Set interrupts and handler
	SEI							; disable CPU interupts
    lda &fe4e
    sta previous_ifr+1

    jsr wait_for_vsync:sta &fe4d

	\\ Not stable but close enough for our purposes
	; Write T1 low now (the timer will not be written until you write the high byte)
    LDA #LO(TimerValue):STA &FE44
    ; Get high byte ready so we can write it as quickly as possible at the right moment
    LDX #HI(TimerValue):STX &FE45            ; start T1 counting		; 4c +1/2c 

  	; Latch T1 to interupt exactly every 50Hz frame
	LDA #LO(FramePeriod):STA &FE46
	LDA #HI(FramePeriod):STA &FE47

	LDA #&7F					; (disable all interrupts)
	STA &FE4E					; R14=Interrupt Enable
	STA &FE43					; R3=Data Direction Register "A" (set keyboard data direction)
	LDA #&C0					; 
	STA &FE4E					; R14=Interrupt Enable

    LDA IRQ1V:STA old_irqv
    LDA IRQ1V+1:STA old_irqv+1

    LDA #LO(irq_handler):STA IRQ1V
    LDA #HI(irq_handler):STA IRQ1V+1		; set interrupt handler
    CLI

    \\ Go!
    \\ Start music player
    {
        lda MUSIC_SLOT_ZP
        bmi no_music
        inc music_enabled
        .no_music
    }

    jsr wait_for_vsync
    jsr show_screen

    \\ Main loop!
    .loop

    {
        .wait_for_task
        lda task_request
        beq wait_for_task

        jsr do_task
        dec task_request
    }

    jmp loop

    .finished
    SEI
    .previous_ifr
    lda #0:sta &fe4e            ; restore interrupts

    LDA old_irqv:STA IRQ1V
    LDA old_irqv+1:STA IRQ1V+1	; set interrupt handler
    CLI

    {
        lda MUSIC_SLOT_ZP
        bmi no_music
        jsr MUSIC_JUMP_SN_RESET
        .no_music
    }

    rts
}

.irq_handler
{
	lda &FC
	pha

	lda &FE4D
	and #&40
	bne is_vsync

 	.return
	pla
	sta &FC
	rti 

    .is_vsync
	\\ Acknowledge vsync interrupt
	sta &FE4D

    \\ Play music
    lda music_enabled
    beq return

    lda music_lock
    bne return

    inc music_lock
    txa:pha:tya:pha

    SET_BGCOL PAL_red

    \\ Update FX Tracker first
    jsr fx_tracker_update

    \\ Handle events
    jsr events_update

    \\ Then update music
	lda &f4:pha
    lda MUSIC_SLOT_ZP
	sta &f4:sta &fe30
    jsr MUSIC_JUMP_VGM_UPDATE
	pla:sta &f4:sta &fe30

    \\ Update vsync counter
    inc vsync_count

    SET_BGCOL PAL_black
    pla:tay:pla:tax
    dec music_lock

	pla
	sta &FC
	rti
}

.old_irqv   EQUW &FFFF

.display_next_buffer
{
    ; display->prev
    ; next->display
    ; prev->next
    ; set CRTC R12 (display HI)
    ldx #12:stx &fe00
    lda next_buffer_HI
    pha
    lsr a:lsr a:lsr a
    sta &fe01
    lda prev_buffer_HI
    sta next_buffer_HI
    lda display_buffer_HI
    sta prev_buffer_HI
    pla
    sta display_buffer_HI
    rts
}

.do_task
{
.^do_task_load_A
    lda #0
.^do_task_load_X
    ldx #0
.^do_task_load_Y
    ldy #0
.^do_task_jmp
    jmp do_nothing
}

MACRO CHECK_TASK_NOT_RUNNING
IF _DEBUG
{
    pha:txa:pha:tya:pha
    lda task_request
    beq ok
    BRK
    .ok
    pla:tay:pla:tax:pla
}
ENDIF
ENDMACRO

.set_task_decrunch
{
; Need to think more about this.
; Doesn't really matter as the JMP won't get called until the
; previous task completes...
    CHECK_TASK_NOT_RUNNING

    sta do_task_load_A+1
    stx do_task_load_X+1
    sty do_task_load_Y+1

    lda #LO(decrunch_to_page_A)
    sta do_task_jmp+1

    lda #HI(decrunch_to_page_A)
    sta do_task_jmp+2

    inc task_request
    rts
}

include "src/fx_tracker.asm"
include "src/assets.asm"

.main_end

\ ******************************************************************
\ *	Additional code modules
\ ******************************************************************

.additional_start
include "lib/screen.asm"
include "lib/exo.asm"
include "lib/disksys.asm"
.additional_end

\ ******************************************************************
\ *	Preinitialised data
\ ******************************************************************

.data_start

.music_filename
EQUS "MUSIC", 13

.bank0_filename
EQUS "BANK0", 13

.default_palette
{
	EQUB &00 + PAL_black
	EQUB &10 + PAL_black
	EQUB &20 + PAL_black
	EQUB &30 + PAL_black
	EQUB &40 + PAL_black
	EQUB &50 + PAL_black
	EQUB &60 + PAL_black
	EQUB &70 + PAL_black
	EQUB &80 + PAL_white
	EQUB &90 + PAL_white
	EQUB &A0 + PAL_white
	EQUB &B0 + PAL_white
	EQUB &C0 + PAL_white
	EQUB &D0 + PAL_white
	EQUB &E0 + PAL_white
	EQUB &F0 + PAL_white
}

.mode4_crtc_regs
{
	EQUB 63    			    ; R0  horizontal total
	EQUB 32					; R1  horizontal displayed
	EQUB 49					; R2  horizontal position
	EQUB &24				; R3  sync width
	EQUB 38					; R4  vertical total
	EQUB 0					; R5  vertical total adjust
	EQUB 32					; R6  vertical displayed
	EQUB 35					; R7  vertical position
	EQUB &F0				; R8  no interlace; cursor off; display off
	EQUB 7					; R9  scanlines per row
	EQUB 32					; R10 cursor start
	EQUB 8					; R11 cursor end
	EQUB HI(screen1_addr/8)	; R12 screen start address, high
	EQUB LO(screen1_addr/8)	; R13 screen start address, low
}

.data_end

\ ******************************************************************
\ *	End address to be saved
\ ******************************************************************

.end

\ ******************************************************************
\ *	Space reserved for runtime buffers not preinitialised
\ ******************************************************************

PAGE_ALIGN
.bss_start

.bss_end

\ ******************************************************************
\ *	Save the executable
\ ******************************************************************

SAVE "build/INVITE", start, end, main

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------"
PRINT "NOVA-INVITE"
PRINT "------"
PRINT "ZP size =", ~zp_end-zp_start, "(",~&80-zp_end,"free)"
PRINT "MAIN size =", ~main_end-main_start
PRINT "LIBRARY size =",~additional_end-additional_start
;PRINT "FX size = ", ~fx_end-fx_start
PRINT "DATA size =",~data_end-data_start
;PRINT "RELOC size =",~reloc_from_end-reloc_from_start
PRINT "BSS size =",~bss_end-bss_start
PRINT "------"
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~screen3_addr-P%
PRINT "------"

\ ******************************************************************
\ *	BANK 0
\ ******************************************************************

CLEAR &8000, &C000
ORG &8000
GUARD &C000
.bank0_start
include "src/bank0.asm"
.bank0_end

SAVE "build/BANK0", bank0_start, bank0_end, bank0_start

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------"
PRINT "BANK 0"
PRINT "------"
;PRINT "ZP size =", ~zp_end-zp_start, "(",~&A0-zp_end,"free)"
;PRINT "MAIN size =", ~main_end-main_start
;PRINT "DATA size =",~data_end-data_start
;PRINT "BSS size =",~bss_end-bss_start
PRINT "------"
PRINT "SIZE =", ~bank0_end-bank0_start
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~&C000-P%
PRINT "------"
