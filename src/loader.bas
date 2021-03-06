MODE7
A%=0:X%=1:R%=USR(&FFF4):M%=(R%DIV256)AND255
tstaddr = &8008
values = &90
unique = &80
RomSel = &FE30
RamSel = &FE32
UsrDat = &FE60
UsrDDR = &FE62
REM Find 16 values distinct from the 16 rom values and each other and save the original rom values
DIM CODE &100
FOR P = 0 TO 2 STEP 2
P%=CODE
[OPT P
SEI
LDY #15        \\ unique values (-1) to find
\\STY UsrDDR     \\ set user via DDRB low bits as output - required for Solidisk SW RAM
TYA            \\ A can start anywhere less than 256-64 as it just needs to allow for enough numbers not to clash with rom, tst and uninitialised tst values
.next_val
LDX #15        \\ sideways bank
ADC #1         \\ will inc mostly by 2, but doesn't matter
.next_slot
STX RomSel
CMP tstaddr
BEQ next_val
CMP unique,X   \\ doesn't matter that we haven't checked these yet as it just excludes unnecessary values, but is safe
BEQ next_val
DEX
BPL next_slot
STA unique,Y
LDX tstaddr
STX values,Y
DEY
BPL next_val
\\ Try to swap each rom value with a unique test value - top down wouldn't work for Solidisk
LDX #0         \\ count up to allow for Solidisk only having 3 select bits
.swap
\\STX UsrDat     \\ set Solidisk SWRAM index
STX RamSel     \\ set RamSel incase it is used
STX RomSel     \\ set RomSel as it will be needed to read, but is also sometimes used to select write
LDA unique,X
STA tstaddr
INX            \\ count up to allow for Solidisk only have 3 select bits
CPX #16
BNE swap
\\ count matching values and restore old values - reverse order to swapping is safe
LDY #16
LDX #15
.tst_restore
STX RomSel
LDA tstaddr
CMP unique,X   \\ if it has changed, but is not this value, it will be picked up in a later bank
BNE not_swr
\\STX UsrDat     \\ set Solidisk SWRAM index
STX RamSel     \\ set RamSel incase it is used
LDA values,X
STA tstaddr
DEY
STX values,Y
.not_swr
DEX
BPL tst_restore
STY values
LDA &F4
STA RomSel     \\ restore original ROM
CLI
RTS
]
NEXT
CALL CODE
PRINT"NOVA ONLINE INVITE by"'"the BITSHIFTERS COLLECTIVE"'"and TORMENT."
PRINT'"(Final version)"
PRINT'"Winning 2nd place in the combined"'"demo compo at the OUTLINE ONLINE party!"
IF NOT(M%=3 OR M%=5) THEN PRINT'"Sorry, this demo requires a BBC Master.":END
PRINT'"Detected ";16-?&90;" SWRAM banks:";
IF ?&90 <> 16 THEN FOR X% = ?&90 TO 15 : PRINT;" ";X%?&90; : NEXT
IF ?&90 > (16-4) THEN PRINT'"Sorry, this demo requires 4x SWRAM banks.":END
IF PAGE > &E00 THEN PRINT'"Sorry, this demo requires PAGE at &E00.":END
PRINT'"Loading...";
ON ERROR ON ERROR OFF:*RUN INVITE
*RUN INVITE
END
