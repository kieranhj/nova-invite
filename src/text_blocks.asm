\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	TEXT BLOCKS
\ ******************************************************************

.text_block_table
{
    EQUW text_block_test            ; c800
    EQUW text_block_credits         ; c801
    EQUW text_block_greetz          ; c802
    EQUW text_block_greetz2         ; c803
    EQUW text_slide_beach           ; c804
    EQUW text_slide_chips           ; c805
    EQUW text_slide_floppy          ; c806
    EQUW text_slide_djsets          ; c807
    EQUW text_slide_patarty         ; c808
    EQUW text_slide_bitshifters     ; c809
    EQUW text_slide_dates           ; c80A
}

.text_block_test
EQUS 12; cls
;             "|--------|"
EQUS 31,0,0,  "!#$&()*./-"
EQUS 31,0,5,  "0123456789"
EQUS 31,0,10, "ABCDEFGHIJ"
EQUS 31,0,15, "KLMNOPQRST"
EQUS 31,0,20, "UVWXYZ"
EQUS 31,0,25, "BITSHIFTERS"
EQUS 0

.text_block_credits
EQUS 12; cls
;             "|--------|"
EQUS 31,0,0,  "CREDITS"
EQUS 31,2,5,  "KIERAN"
EQUS 31,4,10, "RHINO"
EQUS 31,6,15, "SPINY"
EQUS 31,8,20, "HENLEY"
EQUS 31,10,25,"0XC0DE"
EQUS 0

.text_block_greetz
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "GREETZ"
EQUS 31,0,5, "ATE-BIT"
EQUS 31,0,10,"CRTC"
EQUS 31,0,15,"DESIRE"
EQUS 31,0,20,"HOOY"
EQUS 31,0,25,"-PROGRAM"
EQUS 0

.text_block_greetz2
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "LOGICOMA"
EQUS 31,0,5, "POLARITY"
EQUS 31,0,10,"RIFT"
EQUS 31,0,15,"SLIPSTREAM"
EQUS 31,0,20,"YM ROCKERZ"
EQUS 31,0,25,"INV*PHASE"
EQUS 0

.text_slide_beach
EQUS 22, &0E            ; beach
;            "|--------|"
EQUS 31,3,1, "BEACH FUN"
EQUS 31,6,27,"BONFIRE"
EQUS 0

.text_slide_chips
EQUS 22, &0B            ; chips
;            "|--------|"
EQUS 31,3,0, "CHIP SHOP"
EQUS 31,3,27,"BIG QUEUE"
EQUS 0

.text_slide_floppy
EQUS 22, &0F            ; floppy
;            "|--------|"
EQUS 31,1,0, "FLOPPY TOSS"
EQUS 31,2,27,"FREE DISKS!"
EQUS 0

.text_slide_djsets
EQUS 22, &10            ; djsets
;            "|--------|"
EQUS 31,6,0, "DJ SETS"
EQUS 31,3,27,"CHIPTUNES"
EQUS 0

.text_slide_patarty
EQUS 22, &0C            ; patarty
;            "|--------|"
EQUS 31,5,0, "PATARTY"
EQUS 31,8,27,"PARTY"
EQUS 0

.text_slide_bitshifters
EQUS 22, &07            ; bitshifters flux
;            "|--------|"
EQUS 31,0,0, "BITSHIFTERS"
EQUS 31,0,27,"BITSHIFTERS"
EQUS 0

.text_slide_dates
EQUS 22, &04            ; NOVA
;            "|--------|"
EQUS 31,15,7,"ONLINE"
EQUS 31,4,24,"19-21 JUNE"
EQUS 0
