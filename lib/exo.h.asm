; -------------------------------------------------------------------
; zero page addresses used
; -------------------------------------------------------------------
.exo_zp_start
.zp_len_lo      skip 1
.zp_len_hi      skip 1
.zp_bits_hi     skip 1
.zp_bitbuf      skip 1
.zp_dest_lo     skip 1      ; dest addr lo - must come after zp_bitbuf
.zp_dest_hi     skip 1      ; dest addr hi
.zp_src_lo      skip 1
.zp_src_hi      skip 1

.get_crunched_byte
skip 1                      ; LDA abs
.INPOS          skip 2      ; &FFFF
.get_crunched_byte_code
skip 7                      ; inc INCPOS: bne no_carry: inc INPOS+1: .no_carry RTS
.get_crunched_byte_code_end
