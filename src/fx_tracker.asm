\ -*- mode:beebasm -*-
\ ******************************************************************
\ *	FX TRACKER MODULE
\ ******************************************************************

\\ Update tracker counters
.fx_tracker_update
{
    ldx tracker_vsync
    inx
    cpx #TRACK_SPEED
    stx tracker_vsync
    bcc is_mid_line

    ldx #0
    stx tracker_vsync

    \\ Moved to new line in the pattern

    ldx tracker_line
    inx
    cpx #TRACK_PATTERN_LENGTH
    bcc same_pattern

    \\ Moved to new pattern
    inc tracker_pattern

    ldx #0
    .same_pattern
    stx tracker_line

    \\ Beat signature
    ldx #0
    lda tracker_line
    and #TRACK_PATTERN_SEGMENT-1
    cmp #0
    bne not_0
    inx
    .not_0
    cmp #8
    bne not_8
    inx
    .not_8
    cmp #12
    bne not_12
    inx
    .not_12
    stx is_beat_line

    .is_mid_line
    rts
}
