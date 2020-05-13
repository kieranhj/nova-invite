\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	TEXT BLOCKS
\ ******************************************************************

.text_block_table
{
    EQUW text_block_credits
    EQUW text_block_greetz
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
    EQUW 0
}

.text_block_credits
EQUS 12; cls
;             "|-------|------|"
EQUS 31,0,0,  "CREDITS"
EQUS 31,0,3,  "CODE: KIERAN"
EQUS 31,0,5,  "MUSIC: RHINO"
EQUS 31,0,7,  "GRAPHICS: SPINY"
EQUS 31,0,9,  "MUSIC CODE:"
EQUS 31,20,11,"HENLEY"
EQUS 31,0,13, "ADDITIONAL"
EQUS 31,6,15, "ANIMS: 0XCODE"
EQUS 0

.text_block_greetz
EQUS 12; cls
;            "|-------|------|"
EQUS 31,0,0, "GREETZ"
EQUS 31,0,3, "ATE-BIT"
EQUS 31,0,5, "CRTC"
EQUS 31,0,7, "DESIRE"
EQUS 31,0,9, "HOOY-PROGRAM"
EQUS 31,0,11,"INVERSE PHASE"
EQUS 31,0,13,"LOGICOMA"
EQUS 31,0,15,"POLARITY"
EQUS 31,0,17,"RIFT"
EQUS 31,0,19,"SLIPSTREAM"
EQUS 31,0,21,"YM ROCKERZ"
EQUS 0
