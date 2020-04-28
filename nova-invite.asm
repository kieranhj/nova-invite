\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	STNICC BEEB INTRO
\ ******************************************************************

_DEBUG = TRUE
_DEBUG_RASTERS = TRUE
_DEBUG_BEGIN_PAUSED = _DEBUG AND FALSE
_DEBUG_SHOW_PRELOAD = _DEBUG AND FALSE

INCLUDE "src/zp.h.asm"

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

ULA_Mode4   = &88
ULA_Mode8   = &E0

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
    lda &248:cmp #ULA_Mode8:beq done
    LDA #&10+c:STA &FE21
    LDA #&20+c:STA &FE21
    LDA #&30+c:STA &FE21
    LDA #&40+c:STA &FE21
    LDA #&50+c:STA &FE21
    LDA #&60+c:STA &FE21
    LDA #&70+c:STA &FE21
    .done
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
SCREEN_SIZE_BYTES = (SCREEN_WIDTH_PIXELS * SCREEN_HEIGHT_PIXELS) / 8

screen1_addr = &6000
screen2_addr = &4000
screen3_addr = &2000

; Exact time for a 50Hz frame less latch load time
FramePeriod = 312*64-2

; This is when we trigger the next frame draw during the frame
; Essentially how much time we give the main loop to stream the next track
TimerValue = (32+254)*64 - 2*64

KEY_PAUSE_INKEY = -56           ; 'P'
KEY_STEP_FRAME_INKEY = -68      ; 'F'
KEY_STEP_LINE_INKEY = -87       ; 'L'
KEY_NEXT_PATTERN_INKEY = -86    ; 'N'

\ ******************************************************************
\ *	ZERO PAGE
\ ******************************************************************

ORG &00
GUARD zp_top

.zp_start

INCLUDE "lib/exo.h.asm"

.writeptr           skip 2
.music_enabled      skip 1

.display_buffer_HI  skip 1
.next_buffer_HI     skip 1
.prev_buffer_HI     skip 1

.task_request       skip 1
.seed               skip 2

INCLUDE "lib/vgcplayer.h.asm"
INCLUDE "src/fx_tracker.h.asm"

.local_vars         skip 8
.local_top

IF _DEBUG
.debug_writeptr     skip 2
.debug_paused       skip 1
.debug_step         skip 1
.debug_step_mode    skip 1
.pause_pattern      skip 1
.pause_line         skip 1

.pause_key_debounce     skip 1
.step_frame_debounce    skip 1
.step_line_debounce     skip 1
.next_pattern_debounce  skip 1
ENDIF

.zp_end

\ ******************************************************************
\ *	BSS DATA IN LOWER RAM
\ ******************************************************************

ORG &400
GUARD &800
.event_data
incbin "build/events.bin"
.event_data_end

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

    SEI
    lda &fe4e
    sta previous_ifr+1
	LDA #&7F					; (disable all interrupts)
	STA &FE4E					; R14=Interrupt Enable
    CLI

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

    lda &fe44:sta seed
    lda &fe45:sta seed+1

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

    \\ Load Banks
    {
        SWRAM_BANK 5
        ldx #LO(bank0_filename)
        ldy #HI(bank0_filename)
        lda #HI(&8000)
        jsr disksys_load_file

        SWRAM_BANK 6
        ldx #LO(bank1_filename)
        ldy #HI(bank1_filename)
        lda #HI(&8000)
        jsr disksys_load_file

        SWRAM_BANK 7
        ldx #LO(bank2_filename)
        ldy #HI(bank2_filename)
        lda #HI(&8000)
        jsr disksys_load_file
    }

    \\ Load events
    {
        ldx #LO(events_filename)
        ldy #HI(events_filename)
        lda #HI(event_data)
        jsr disksys_load_file
    }

    \\ Set MODE w/out using OS.

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
    ldx #LO(mode4_default_palette)
    ldy #HI(mode4_default_palette)
	jsr set_palette

	\\ Set ULA register
	lda #ULA_Mode4
	sta &248			; OS copy
	sta &fe20

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

    \\ This sets the first preload fn.
    \\ Should we wait for it to complete?
    jsr events_init

	\\ Set interrupts and handler
	SEI							; disable CPU interupts
    ldx #2: jsr wait_frames

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

    IF _DEBUG_BEGIN_PAUSED
    lda #1:sta debug_paused
    lda events_line:sta pause_line
    ENDIF

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
        ldx events_frame
        bne skip_preload

        \\ Poll the preload system.
        jsr preload_update

        .skip_preload
        lda task_request
        beq wait_for_task

        \\ Do our background task.
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

    jmp MUSIC_JUMP_SN_RESET
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

    txa:pha:tya:pha
    SET_BGCOL PAL_red

    IF _DEBUG
    {
        lda debug_paused
        beq do_update

        lda debug_step
        beq skip_update

        dec debug_step
        .do_update
    }
    ENDIF

    \\ Update frame counter.
    {
        ldx events_frame
        inx
        cpx #TRACK_SPEED
        bcc ok
        ldx #0
        .ok
        stx events_frame

        \\ Events only take play at the track speed.
        cpx #0
        bne skip_line_updates

        \\ Handle events
        jsr events_update
        \\ Preload system now polled in main loop.
        .skip_line_updates
    }

    \\ Then per-frame func.
    jsr do_per_frame_fn

    \\ Then update music - could be on a mid-frame timer.
    jsr MUSIC_JUMP_VGM_UPDATE

    IF _DEBUG
    .skip_update
    {
        jsr do_pause_controls       ; C set = paused
        bcs show_debug

        lda #1:sta debug_step

        .show_debug
        jsr fx_tracker_show_debug
    }
    ENDIF

    SET_BGCOL PAL_black
    pla:tay:pla:tax

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

.display_prev_buffer
{
    ; display->prev
    ; prev->display
    ; next<>next
    ; set CRTC R12 (display HI)
    ldx #12:stx &fe00
    lda prev_buffer_HI
    pha
    lsr a:lsr a:lsr a
    sta &fe01
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

.do_per_frame_fn
{
    jmp do_nothing    
}

.set_per_frame_do_nothing
{
    lda #LO(do_nothing)
    sta do_per_frame_fn+1
    lda #HI(do_nothing)
    sta do_per_frame_fn+2
    rts
}

IF _DEBUG
.do_pause_controls
{
    lda debug_step_mode
    beq not_stepping

    cmp #1:bne step_to_pattern

    \\ Step to line
    lda pause_line
    cmp events_line
    beq exit_and_update
    bne done_stepping

    .step_to_pattern
    lda pause_pattern
    cmp events_pattern
    beq exit_and_update

    \\ Done stepping
    .done_stepping
    lda #0:sta debug_step_mode

    .not_stepping
    lda #pause_key_debounce
    ldx #KEY_PAUSE_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_pause

    \\ Pause key pressed
    lda debug_paused
    bne exiting_pause

    \\ Entering pause
    jsr MUSIC_JUMP_SN_RESET
    .exiting_pause

    \\ Toggle pause
    lda debug_paused:eor #1:sta debug_paused

    .not_pressed_pause
    lda debug_paused
    beq exit_and_update

    \\ Check for step frame
    lda #step_frame_debounce
    ldx #KEY_STEP_FRAME_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_step_frame

    .exit_and_update
    clc
    rts

    .not_pressed_step_frame
    \\ Check for step line
    lda #step_line_debounce
    ldx #KEY_STEP_LINE_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_step_line

    lda events_line
    sta pause_line
    lda #1:sta debug_step_mode
    bne exit_and_update

    .not_pressed_step_line
    \\ Check for step pattern
    lda #next_pattern_debounce
    ldx #KEY_NEXT_PATTERN_INKEY AND 255
    jsr debug_check_key
    bne not_pressed_next_pattern

    lda events_pattern
    sta pause_pattern
    lda #2:sta debug_step_mode
    bne exit_and_update

    .not_pressed_next_pattern
    sec
    rts
}
ENDIF

include "src/fx_tracker.asm"
include "src/anims.asm"
include "src/music_jump.asm"

.main_end

\ ******************************************************************
\ *	Additional code modules
\ ******************************************************************

.additional_start
include "lib/screen.asm"
include "lib/exo.asm"
include "lib/disksys.asm"
include "lib/debug4.asm"
.additional_end

\ ******************************************************************
\ *	Preinitialised data
\ ******************************************************************

.data_start

.music_filename     EQUS "MUSIC", 13
.bank0_filename     EQUS "BANK0", 13
.bank1_filename     EQUS "BANK1", 13
.bank2_filename     EQUS "BANK2", 13
.events_filename    EQUS "EVENTS", 13

.mode4_default_palette
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

.mode8_default_palette
{
	EQUB &00 + PAL_black
	EQUB &10 + PAL_red
	EQUB &20 + PAL_green
	EQUB &30 + PAL_yellow
	EQUB &40 + PAL_blue
	EQUB &50 + PAL_magenta
	EQUB &60 + PAL_cyan
	EQUB &70 + PAL_white
	EQUB &80 + PAL_black
	EQUB &90 + PAL_red
	EQUB &A0 + PAL_green
	EQUB &B0 + PAL_yellow
	EQUB &C0 + PAL_blue
	EQUB &D0 + PAL_magenta
	EQUB &E0 + PAL_cyan
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

include "src/asset_tables.asm"

MOD15_MAX = 255
.mod15_plus1_asl4_table                ; could be PAGE_ALIGN'd
{
    FOR n,0,255,1
    EQUB ((n MOD 15)+1) << 4
    NEXT
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
\ *	BANK 0: IMAGES
\ ******************************************************************

CLEAR &8000, &C000
ORG &8000
GUARD &C000
.bank0_start
include "src/image_data.asm"
.bank0_end

SAVE "build/BANK0", bank0_start, bank0_end, bank0_start

PRINT "------"
PRINT "BANK 0"
PRINT "------"
PRINT "SIZE =", ~bank0_end-bank0_start
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~&C000-P%
PRINT "------"

\ ******************************************************************
\ *	BANK 1: ANIMS
\ ******************************************************************

CLEAR &8000, &C000
ORG &8000
GUARD &C000
.bank1_start
include "src/anims_data.asm"
.bank1_end

SAVE "build/BANK1", bank1_start, bank1_end, bank1_start

PRINT "------"
PRINT "BANK 1"
PRINT "------"
PRINT "SIZE =", ~bank1_end-bank1_start
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~&C000-P%
PRINT "------"

\ ******************************************************************
\ *	BANK 2: ANIMS #2
\ ******************************************************************

CLEAR &8000, &C000
ORG &8000
GUARD &C000
.bank2_start
.exo_anims_triangle
INCBIN "build/triangle.exo"
.exo_anims_claw
INCBIN "build/claw.exo"
.bank2_end

SAVE "build/BANK2", bank2_start, bank2_end, bank2_start

PRINT "------"
PRINT "BANK 2"
PRINT "------"
PRINT "SIZE =", ~bank2_end-bank2_start
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~&C000-P%
PRINT "------"

\ ******************************************************************
\ *	BANK 3: MUSIC
\ ******************************************************************

CLEAR &8000, &C000
ORG &8000
GUARD &C000
.bank3_start
include "src/music.asm"
.bank3_end

SAVE "build/MUSIC", bank3_start, bank3_end, bank3_start

PRINT "------"
PRINT "BANK 3"
PRINT "------"
PRINT "SIZE =", ~bank2_end-bank2_start
PRINT "HIGH WATERMARK =", ~P%
PRINT "FREE =", ~&C000-P%
PRINT "------"

\ ******************************************************************
\ *	EVENTS DATA
\ ******************************************************************

PRINT "------"
PRINT "EVENTS"
PRINT "------"
PRINT "SIZE =", ~event_data_end-event_data
PRINT "FREE =", ~&800-event_data_end
PRINT "------"
