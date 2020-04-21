\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	DISC BUILD
\ ******************************************************************

LOAD_ADDRESS = &FF1100
EXEC_ADDRESS = &FF1100
SWRAM_ADDRESS = &8000

PUTFILE "build/INVITE", "!BOOT", LOAD_ADDRESS, EXEC_ADDRESS
PUTFILE "build/MUSIC", "MUSIC", SWRAM_ADDRESS, SWRAM_ADDRESS
PUTFILE "build/BANK0", "BANK0", SWRAM_ADDRESS, SWRAM_ADDRESS
