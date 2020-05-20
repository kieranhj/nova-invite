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
    EQUW text_slide_firealarm       ; c80B
    EQUW text_block_greetz3         ; c80C
    EQUW text_block_just_dates      ; c80D
    EQUW text_block_see_you         ; c80E
    EQUW text_block_compos          ; c80F
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
EQUS 31,0,0,  "CREDITS*"
EQUS 31,2,6,  "KIERAN"
EQUS 31,4,11, "RHINO"
EQUS 31,6,16, "SPINY"
EQUS 31,8,21, "HENLEY"
EQUS 31,10,26,"0XC0DE"
EQUS 0

.text_block_greetz
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "GREETZ*"
EQUS 31,2,6, "ATE-BIT"
EQUS 31,3,11,"CRTC"
EQUS 31,4,16,"DESIRE"
EQUS 31,5,21,"HOOY"
EQUS 31,6,26,"-PROGRAM"
EQUS 0

.text_block_greetz2
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "GREETZ*"
EQUS 31,2,6, "LOGICOMA"
EQUS 31,3,11,"POLARITY"
EQUS 31,4,16,"RIFT"
EQUS 31,4,21,"SLIPSTREAM"
EQUS 31,3,26,"YM ROCKERZ"
EQUS 0

.text_block_greetz3
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "GREETZ*"
EQUS 31,2,6, "BUDBRAIN"
EQUS 31,3,11,"INVERSE"
EQUS 31,8,16,"PHASE"
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
EQUS 31,0,28,"BITSHIFTERS"
EQUS 0

.text_slide_dates
EQUS 22, &15            ; NOVA URL
;            "|--------|"
EQUS 31,4,22,"19-21 JUNE"
EQUS 0

.text_slide_firealarm
EQUS 22, &11            ; fire alarm
;            "|--------|"
EQUS 31,3,0, "FIRE ALARM"
EQUS 31,3,27,"(OPTIONAL)"
EQUS 0

.text_block_just_dates
EQUS 12
;            "|--------|"
EQUS 31,4,14,"19-21 JUNE"
EQUS 0

.text_block_see_you
EQUS 12
;             "|--------|"
EQUS 31,7,7,  "SEE YOU"
EQUS 31,8,12, "ONLINE!"
EQUS 31,4,20, "19-21 JUNE"
EQUS 0

.text_block_compos
EQUS 12
;             "|--------|"
EQUS 31,3,1,  "COMPOS!"
EQUS 31,4,6,  "COMPOS!"
EQUS 31,5,11, "COMPOS!"
EQUS 31,6,16, "COMPOS!"
EQUS 31,7,21, "COMPOS!"
EQUS 31,8,26, "COMPOS!"
EQUS 0
