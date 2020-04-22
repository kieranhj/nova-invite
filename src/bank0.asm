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
EQUB LO(exo_data_screen7)
EQUB LO(exo_data_screen8)
EQUB LO(exo_data_screen9)
EQUB LO(exo_data_screen10)

.exo_screens_table_HI
EQUB HI(exo_data_screen1)
EQUB HI(exo_data_screen2)
EQUB HI(exo_data_screen3)
EQUB HI(exo_data_screen4)
EQUB HI(exo_data_screen5)
EQUB HI(exo_data_screen6)
EQUB HI(exo_data_screen7)
EQUB HI(exo_data_screen8)
EQUB HI(exo_data_screen9)
EQUB HI(exo_data_screen10)

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
.exo_data_screen7
INCBIN "build/atom.exo"
.exo_data_screen8
INCBIN "build/cross.exo"
.exo_data_screen9
INCBIN "build/galaxy.exo"
.exo_data_screen10
INCBIN "build/world.exo"

.bank0_data_end
