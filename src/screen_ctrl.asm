\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	SCREEN CTRL COMMANDS
\ ******************************************************************

.swap_to_prev_screen_image
{
    jsr set_mode_4
    lda last_fg_colour:jsr set_mode4_fg_colour
    lda last_bg_colour:jsr set_mode4_bg_colour
    jsr set_per_frame_do_nothing
    jsr set_per_irq_do_nothing
    jmp display_prev_buffer
}

.swap_to_prev_screen_anim
{
    jsr set_mode_8
    jsr set_all_black_palette
    lda #1:sta anims_frame_delay    ; do per frame update immediately
    jsr set_per_irq_do_nothing
    jmp display_prev_buffer
}
