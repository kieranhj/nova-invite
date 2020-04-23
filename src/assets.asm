\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	ASSET SYSTEM
\ ******************************************************************

.assets_table_LO
EQUB LO(exo_asset_big_n)
EQUB LO(exo_asset_big_o)
EQUB LO(exo_asset_big_v)
EQUB LO(exo_asset_big_a)
EQUB LO(exo_asset_nova)
EQUB LO(exo_asset_nova_4)
EQUB LO(exo_asset_atom)
EQUB LO(exo_asset_cross)
EQUB LO(exo_asset_galaxy)
EQUB LO(exo_asset_world)
EQUB LO(exo_asset_bs_teletext)

.assets_table_HI
EQUB HI(exo_asset_big_n)
EQUB HI(exo_asset_big_o)
EQUB HI(exo_asset_big_v)
EQUB HI(exo_asset_big_a)
EQUB HI(exo_asset_nova)
EQUB HI(exo_asset_nova_4)
EQUB HI(exo_asset_atom)
EQUB HI(exo_asset_cross)
EQUB HI(exo_asset_galaxy)
EQUB HI(exo_asset_world)
EQUB HI(exo_asset_bs_teletext)

; might also need SWRAM# ?

; X = asset identifer
; Y = screen no
.asset_load_X_to_screen_Y
{
    lda screen_buffer_HI, Y
    pha

    IF _DEBUG
    {
        lda asset_load_active
        beq ok
        BRK
        .ok
    }
    ENDIF
    
    inc asset_load_active

    ldy assets_table_HI, X
    lda assets_table_LO, X
    tax
    pla

    jsr decrunch_to_page_A

    dec asset_load_active
    rts
}
