GETIN = $ffe4

DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d
G_KEY = $47
Q_KEY = $51
F1_KEY = $85

;-------------------------------------------------------------------------------
; handle input, set carry flag if continuing
handleKeypress
        jsr GETIN
        beq handleKeypress

        cmp #DOWN_ARROW
        beq down

        cmp #UP_ARROW
        beq up

        cmp #RIGHT_ARROW
        beq right

        cmp #LEFT_ARROW
        beq left

        cmp #F1_KEY
        beq showHelpScreen

        cmp #G_KEY
        beq go
                
        cmp #Q_KEY
        clc
        beq exit

        sec
exit    rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move down one row
down    ldx #bytesInLine
        jsr moveDown
        sec
        rts

; move up one row
up      ldx #bytesInLine
        jsr moveUp
        sec
        rts

; move down one screen
right   ldx #displayedBytes
        jsr moveDown
        sec
        rts

; move up one screen
left    ldx #displayedBytes
        jsr moveUp
        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; add x to top left address
moveDown
        txa
        clc
        adc base
        bcc @skip
        inc base+1
@skip   sta base
        rts

; subtract x from top left address
moveUp
        lda base
        stx base
        sec
        sbc base
        bcs @skip
        dec base+1
@skip   sta base
        rts
;-------------------------------------------------------------------------------
