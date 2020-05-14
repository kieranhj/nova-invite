\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	TEXT BLOCKS
\ ******************************************************************

.text_block_table
{
    EQUW text_block_test
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

.text_block_test
EQUS 12; cls
;             "|--------|"
EQUS 31,0,0,  "!#$&()*./-"
EQUS 31,0,5,  "0123456789"
EQUS 31,0,10, "ABCDEFGHIJ"
EQUS 31,0,15, "KLMNOPQRST"
EQUS 31,0,20, "UVWXYZ"
EQUS 0

.text_block_credits
EQUS 12; cls
;             "|--------|"
EQUS 31,0,0,  "CREDITS"
EQUS 31,2,5,  "KIERAN"
EQUS 31,4,10, "RHINO"
EQUS 31,6,15, "SPINY"
EQUS 31,8,20, "HENLEY"
EQUS 31,10,25,"0XCODE"
EQUS 0

.text_block_greetz
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0, "GREETZ"
EQUS 31,0,5, "ATE-BIT"
EQUS 31,0,10,"CRTC"
EQUS 31,0,15,"DESIRE"
EQUS 31,0,20,"HOOY-PROGRAM"
EQUS 31,0,25,"INVERSE PHASE"

.text_block_greetz2
EQUS 12; cls
;            "|--------|"
EQUS 31,0,0,"LOGICOMA"
EQUS 31,0,5,"POLARITY"
EQUS 31,0,10,"RIFT"
EQUS 31,0,15,"SLIPSTREAM"
EQUS 31,0,20,"YM ROCKERZ"
EQUS 0
