;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-packer
;******************************************************************


; VGM player supports VGC files that are plain LZ4 or Huffman LZ4 if ENABLE_HUFFMAN is TRUE
; Huffman decoding is variable speed and requires more Zero page, so...
; For optimal performance & memory usage you can disable huffman support.
; (just make sure you compile your VGC files without huffman of course) 
ENABLE_HUFFMAN = FALSE

; Enable this to capture the SN chip register settings (for fx etc.)
ENABLE_VGM_FX = TRUE

;-------------------------------
; workspace/zeropage vars
;-------------------------------

; Declare where VGM player should locate its zero page vars
; VGM player uses:
;  8 zero page vars without huffman
; 19 zero page vars with huffman
.VGM_ZP SKIP 8 ; must be in zero page 

; declare zero page registers used for each compressed stream (they are context switched)
lz_zp = VGM_ZP + 0
zp_stream_src   = lz_zp + 0    ; stream data ptr LO/HI          *** ONLY USED 1-2 TIMES PER FRAME ***, not worth ZP?
; none of the following have to be zp for indirect addressing reasons.
zp_literal_cnt  = lz_zp + 2    ; literal count LO/HI, 7 references
zp_match_cnt    = lz_zp + 4    ; match count LO/HI, 10 references
; temporary vars
zp_temp = lz_zp + 6 ; 2 bytes ; used only by lz_decode_byte and lz_fetch_count, does not need to be zp apart from memory/speed reasons



; The following vars only apply if Huffman support is enabled
IF ENABLE_HUFFMAN

; we re-use the LZ read ptr, since the huffman routine replaces the lz_fetch_byte
huff_readptr    = zp_stream_src 

.HUFF_ZP SKIP 11 ;= zp_temp + 2

; huffman decoder stream context - CHECK:needs to be in ZP? prefix with zp if so
zp_huff_bitbuffer  = HUFF_ZP + 0    ; huffman decoder bit buffer - 1 byte, referenced by inner loop
zp_huff_bitsleft   = HUFF_ZP + 1    ; huffman decoder bit buffer size - 1 byte, referenced by inner loop

; these variables are only used during a byte fetch - ie. not stream specific.
; ZP only for byte & cycle speed. Could be absolute memory.
huff_code       = HUFF_ZP + 2 ; 2
huff_firstcode  = HUFF_ZP + 4 ; 2
huff_startindex = HUFF_ZP + 6 ; 1
huff_codesize   = HUFF_ZP + 7 ; 1
huff_index      = HUFF_ZP + 8 ; 2
huff_numcodes   = HUFF_ZP + 10 ; 1

ENDIF ; ENABLE_HUFFMAN


; when mounting a VGM file we use these four variables as temporaries
; they are not speed or memory critical.
; they may need to be zero page due to indirect addressing
zp_block_data = zp_stream_src ; re-uses zp_stream_src, must be zp ; zp_buffer+0 ; must be zp
zp_block_size = zp_temp+0 ; does not need to be zp

; Sound chip data from the vgm player
IF ENABLE_VGM_FX
.vgm_fx SKIP 12 ; was 11
; first 8 bytes are:
; tone0 LO, tone1 LO, tone2 LO, tone3, vol0, vol1, vol2, vol3 (all 4-bit values)
; next 3 bytes are:
; tone0 HI, tone1 HI, tone2 HI (all 6-bit values)
VGM_FX_TONE0_LO = 0
VGM_FX_TONE1_LO = 1
VGM_FX_TONE2_LO = 2
VGM_FX_TONE3_LO = 3 ; noise
VGM_FX_VOL0     = 4
VGM_FX_VOL1     = 5
VGM_FX_VOL2     = 6
VGM_FX_VOL3     = 7 ; noise
VGM_FX_TONE0_HI = 8
VGM_FX_TONE1_HI = 9
VGM_FX_TONE2_HI = 10
ENDIF
