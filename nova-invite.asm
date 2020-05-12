\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	STNICC BEEB INTRO
\ ******************************************************************

_DEBUG = TRUE
_DEBUG_RASTERS = FALSE
_DEBUG_BEGIN_PAUSED = _DEBUG AND FALSE
_DEBUG_SHOW_PRELOAD = _DEBUG AND FALSE
_DEBUG_STATUS_BAR = _DEBUG AND TRUE

INCLUDE "src/zp.h.asm"
include "src/music_jump.asm"

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
    lda #c:jsr debug_rasters_set_bg_col
}
ENDIF
ENDMACRO

MACRO SWRAM_BANK b
{
    LDA #b:STA &F4:STA &FE30
}
ENDMACRO

MACRO SET_PALETTE_REG
IF _DEBUG_STATUS_BAR
{
    pha:lsr a:lsr a:lsr a:lsr a
    sta write_value+1:pla
    .write_value
    sta &00
    sta &fe21
}
ELSE
    sta &fe21
ENDIF
ENDMACRO


MACRO RND
{
    LDA seed
    ASL A
    ASL A
    CLC
    ADC seed
    CLC
    ADC #&45
    STA seed
}
ENDMACRO

MACRO RND16
{
    lda seed+1
    lsr a
    rol seed
    bcc no_eor
    eor #&b4
    .no_eor
    sta seed+1
    eor seed
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
QuarterScreenPeriod = 64*64-2

; This is when we trigger the next frame draw during the frame
; Essentially how much time we give the main loop to stream the next track
IF _DEBUG_STATUS_BAR
TimerValue = (32+254-9)*64 - 2*64
TopOfFrameTimeValue = (56+9)*64-2
ELSE
TimerValue = (32+254)*64 - 2*64
TopOfFrameTimeValue = 56*64-2
ENDIF

KEY_PAUSE_INKEY = -56           ; 'P'
KEY_STEP_FRAME_INKEY = -68      ; 'F'
KEY_STEP_LINE_INKEY = -87       ; 'L'
KEY_NEXT_PATTERN_INKEY = -86    ; 'N'
KEY_RESTART_INKEY = -52         ; 'R'
KEY_DISPLAY_INKEY = -51         ; 'D'

\ ******************************************************************
\ *	ZERO PAGE
\ ******************************************************************

ORG &00
GUARD zp_top

.zp_start

IF _DEBUG_STATUS_BAR
.debug_palette_copy skip 16     ; must be at &00!
ENDIF

INCLUDE "lib/exo.h.asm"

.readptr            skip 2
.writeptr           skip 2
.music_enabled      skip 1

.display_buffer_HI  skip 1
.next_buffer_HI     skip 1
.prev_buffer_HI     skip 1

.task_request       skip 1
.seed               skip 2
.temp               skip 8

.irq_section        skip 1

INCLUDE "lib/vgcplayer.h.asm"
INCLUDE "src/fx_tracker.h.asm"
INCLUDE "src/debug_tracker.h.asm"

.zp_end

\ ******************************************************************
\ *	BSS DATA IN LOWER RAM
\ ******************************************************************

EVENTS_DATA_MAX = &900

ORG &400
GUARD &400 + EVENTS_DATA_MAX
.event_data
incbin "build/events.bin"
.event_data_end

RELOC_SPACE = &300
ORG &E00
GUARD &E00 + RELOC_SPACE - 1
.reloc_to_start
.mod15_plus1_asl4_table
skip &100
.ping_pong_table
skip &100
.alt_pixels_to_lh
skip &AB
.mult16_table
skip 16
.reloc_to_end

\ ******************************************************************
\ *	CODE START
\ ******************************************************************

ORG &1100
GUARD screen3_addr + RELOC_SPACE

.start
.main_start

\ ******************************************************************
\ *	Code entry
\ ******************************************************************

.main
{
    SEI
    lda &fe4e
    sta previous_ifr+1
	LDA #&7F					; (disable all interrupts)
	STA &FE4E					; R14=Interrupt Enable

    LDA IRQ1V:STA old_irqv
    LDA IRQ1V+1:STA old_irqv+1
    CLI

    \\ Consts for now
    lda #4:sta MUSIC_SLOT_ZP

	\\ Relocate data to lower RAM
	lda #HI(reloc_from_start)
	ldx #HI(reloc_to_start)
	ldy #HI(reloc_to_end - reloc_to_start + &ff)
	jsr disksys_copy_block

    \\ Load music into SWRAM (if available)
    {
        lda MUSIC_SLOT_ZP
        sta &f4:sta &fe30
        ldx #LO(music_filename)
        ldy #HI(music_filename)
        lda #HI(&8000)
        jsr disksys_load_file
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

    IF _DEBUG
    IF _DEBUG_BEGIN_PAUSED
    lda #1
    ELSE
    lda #0
    ENDIF

    .*restart
    sta debug_begin_paused+1
    ENDIF

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

    lda &fe44:sta seed
    lda &fe45:sta seed+1

    \\ This also initiates a preload update.
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
    sta &fe6e                   ; uservia
	STA &FE43					; R3=Data Direction Register "A" (set keyboard data direction)
	LDA #&C0					; 
	STA &FE4E					; R14=Interrupt Enable
    lda #64
    sta &fe4b                   ; T1 free-run mode
    sta &fe6b                   ; uservia

    LDA #LO(irq_handler):STA IRQ1V
    LDA #HI(irq_handler):STA IRQ1V+1		; set interrupt handler
    CLI

    IF _DEBUG
    .debug_begin_paused
    lda #0:sta debug_paused
    sta debug_msg_no
    lda events_line:sta pause_line
    lda #1:sta debug_show_status
    ENDIF

    \\ Complete any initial preload task.
    {
        lda task_request
        beq no_initial_task
        jsr do_task
        dec task_request
        .no_initial_task
    }

    \\ Start music player
    {
        lda MUSIC_SLOT_ZP
        sta &f4:sta &fe30

        \\ Initialise music
        MUSIC_JUMP_INIT_TUNE
        inc music_enabled
    }

    \\ Go!
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

    MUSIC_JUMP_SN_RESET
}

.irq_handler
{
	lda &FC
	pha

	lda &FE4D
	and #&40
	bne is_timer1_sysvia

	lda &FE6D
	and #&40
	beq return
	sta &FE6D

    \\ USERVIA Timer 1
    txa:pha:tya:pha
    .^do_per_irq_fn
    nop:nop:nop
    pla:tay:pla:tax
    
    dec irq_section
    bpl return

    lda #&7f:sta &fe6e          ; disable USERVIA T1    

 	.return
	pla
	sta &FC
	rti 

    .is_timer1_sysvia
	\\ Acknowledge vsync interrupt
	sta &FE4D

    \\ Play music
    lda music_enabled
    beq return

    \\ Set up USERVIA

	; Write T1 low now (the timer will not be written until you write the high byte)
    LDA #LO(TopOfFrameTimeValue):STA &FE64
    LDA #HI(TopOfFrameTimeValue):STA &FE65            ; start T1 counting

  	; Latch T1 to interupt exactly every 50Hz frame
	LDA #LO(QuarterScreenPeriod):STA &FE66
	LDA #HI(QuarterScreenPeriod):STA &FE67

    lda #3:sta irq_section
    lda #&c0:sta &fe6e          ; enable USERVIA T1

    txa:pha:tya:pha

    IF _DEBUG_STATUS_BAR
    DEBUG_highlight_status_bar
    ENDIF

    IF _DEBUG
    {
        lda debug_paused
        beq do_update

        lda debug_step
        bne do_step
        jmp skip_update
        .do_step

        dec debug_step
        .do_update
    }
    ENDIF

    SET_BGCOL PAL_red

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
    .^do_per_frame_fn
    jsr do_nothing

    SET_BGCOL PAL_blue

    \\ Then update music - could be on a mid-frame timer.
    MUSIC_JUMP_VGM_UPDATE

    IF _DEBUG
    .skip_update
    {
        DEBUG_do_pause_controls       ; C set = paused
        bcs show_debug

        lda #1:sta debug_step

        .show_debug
        SET_BGCOL PAL_green
        CLI                             \\ this bit is slow...
        DEBUG_show_tracker_info
        SEI
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
    pha
    lda task_request
    beq ok
    DEBUG_ERROR debug_msg_error_task
    .ok
    pla
}
ENDIF
ENDMACRO

.set_per_frame_do_nothing
{
    lda #LO(do_nothing)
    sta do_per_frame_fn+1
    lda #HI(do_nothing)
    sta do_per_frame_fn+2
    rts
}

.set_per_irq_do_nothing
{
    lda #&ea                ; nop
    sta do_per_irq_fn+0
    sta do_per_irq_fn+1
    sta do_per_irq_fn+2
    rts
}

.set_per_irq_fn
{
    lda #&20                ; jsr
    sta do_per_irq_fn+0
    stx do_per_irq_fn+1
    sty do_per_irq_fn+2
    rts
}

IF _DEBUG_RASTERS
.debug_rasters_set_bg_col
{
    sta &FE21:sta load_c+1
    lda &248:cmp #ULA_Mode8:beq done
    .load_c
    lda #0
    eor #&10:STA &FE21
    eor #&30:STA &FE21
    eor #&10:STA &FE21
    eor #&70:STA &FE21
    eor #&10:STA &FE21
    eor #&30:STA &FE21
    eor #&10:STA &FE21
    .done
    rts
}
ENDIF

.main_end

\ ******************************************************************
\ *	FX MODULES
\ ******************************************************************

.fx_start
include "src/fx_tracker.asm"
include "src/anims.asm"
include "src/special_fx.asm"
include "src/screen_ctrl.asm"
.fx_end

\ ******************************************************************
\ *	LIBRARY MODULES
\ ******************************************************************

.library_start
include "lib/screen.asm"
include "lib/exo.asm"
include "lib/disksys.asm"
.library_end

\ ******************************************************************
\ *	Preinitialised data
\ ******************************************************************

.data_start

.music_filename     EQUS "MUSIC", 13
.bank0_filename     EQUS "BANK0", 13
.bank1_filename     EQUS "BANK1", 13
.bank2_filename     EQUS "BANK2", 13
.events_filename    EQUS "EVENTS", 13

.char_def           skip 9

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
	EQUB 45					; R2  horizontal position
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

include "src/control_codes.asm"
include "src/anims_data.asm"

.data_end

\ ******************************************************************
\ *	Relocatable data
\ ******************************************************************

PAGE_ALIGN
.reloc_from_start
MOD15_MAX = 240
.reloc_mod15_plus1_asl4_table         ; could be PAGE_ALIGN'd
{
    FOR n,0,255,1
    EQUB ((n MOD 15)+1) << 4
    NEXT
}

PING_PONG_MAX = 224
.reloc_ping_pong_table                ; could be PAGE_ALIGN'd
{
    FOR n,0,255,1
    a = n MOD 28
    b = 14 - ABS(a-14)
    EQUB (b+1) << 4
    NEXT
}

.reloc_alt_pixels_to_lh
{
    FOR n,0,&AA,1
    EQUB (n AND &80) OR ((n AND &20)<<1) OR ((n AND &8)<<2) OR ((n AND &2)<<3)
    NEXT
}

.reloc_mult16_table
{
    FOR n,0,15,1
    EQUB n*16
    NEXT
}
.reloc_from_end

\ ******************************************************************
\ *	End address to be saved
\ ******************************************************************

.end

\ ******************************************************************
\ *	Save the executable
\ ******************************************************************

SAVE "build/INVITE", start, end, main

\ ******************************************************************
\ *	Space reserved for runtime buffers not preinitialised
\ ******************************************************************

ORG reloc_from_start
GUARD screen3_addr

.bss_start
.bss_end

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------"
PRINT "NOVA-INVITE"
PRINT "------"
PRINT "ZP size =", ~zp_end-zp_start, "(",~&80-zp_end,"free)"
PRINT "MAIN size =", ~main_end-main_start
PRINT "FX size = ", ~fx_end-fx_start
PRINT "LIBRARY size =",~library_end-library_start
PRINT "DATA size =",~data_end-data_start
PRINT "RELOC size =",~reloc_from_end-reloc_from_start
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
include "src/image_assets.asm"

.exo_anims_swirl
INCBIN "build/swirl.exo"
.exo_anims_tunnel
INCBIN "build/tunnel.exo"
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
.exo_anims_world
INCBIN "build/world.exo"
.exo_anims_shift
INCBIN "build/shift.exo"
.exo_anims_turbluent
INCBIN "build/turbulent.exo"
.exo_anims_triangle
INCBIN "build/triangle.exo"
.exo_anims_claw
INCBIN "build/claw.exo"
.exo_anims_star
INCBIN "build/star.exo"
.exo_anims_circle
INCBIN "build/circle.exo"
.exo_anims_faces
INCBIN "build/faces.exo"
.exo_anims_vupal
INCBIN "build/vupal.exo"
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
.exo_anims_square
INCBIN "build/square.exo"
.exo_anims_kaleidoscope
INCBIN "build/kaleidoscope.exo"
.exo_anims_sine_wave
INCBIN "build/sine.exo"
.exo_anims_hbars
INCBIN "build/hbars.exo"
.exo_anims_dbars
INCBIN "build/dbars.exo"
.exo_anims_burst
INCBIN "build/burst.exo"
.exo_anims_particl
INCBIN "build/particl.exo"
.exo_anims_rotor
INCBIN "build/rotor.exo"
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
.music_start
include "src/music.asm"
.music_end

.debug_start
include "src/debug_tracker.asm"
include "lib/debug_mode4.asm"
.debug_end

.bank3_end

SAVE "build/MUSIC", bank3_start, bank3_end, bank3_start

PRINT "------"
PRINT "BANK 3"
PRINT "------"
PRINT "MUSIC size =", ~music_end-music_start
PRINT "DEBUG CODE size =",~debug_end-debug_start
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
PRINT "FREE =", ~EVENTS_DATA_MAX-event_data_end
PRINT "------"
