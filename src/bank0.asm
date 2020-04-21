\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FX MODULE
\ ******************************************************************

.bank0_data_start
.exo_screens_table_LO
EQUB LO(exo_data_screen1)
EQUB LO(exo_data_screen2)
EQUB LO(exo_data_screen3)
EQUB LO(exo_data_screen4)
EQUB LO(exo_data_screen5)
EQUB LO(exo_data_screen6)

.exo_screens_table_HI
EQUB HI(exo_data_screen1)
EQUB HI(exo_data_screen2)
EQUB HI(exo_data_screen3)
EQUB HI(exo_data_screen4)
EQUB HI(exo_data_screen5)
EQUB HI(exo_data_screen6)

.exo_data_screen1
INCBIN "build/n.exo"
.exo_data_screen2
INCBIN "build/o.exo"
.exo_data_screen3
INCBIN "build/v.exo"
.exo_data_screen4
INCBIN "build/a.exo"
.exo_data_screen5
INCBIN "build/nova.exo"
.exo_data_screen6
INCBIN "build/nova4.exo"
.bank0_data_end
