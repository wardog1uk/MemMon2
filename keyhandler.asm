GETIN = $ffe4

DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d
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

        cmp #Q_KEY 
        clc
        beq exit

        sec
exit    rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move down one row
down    ldx #$08
        jsr moveDown
        sec
        rts

; move up one row
up      ldx #$08
        jsr moveUp
        sec
        rts

; move down one screen
right   ldx #$b0
        jsr moveDown
        sec
        rts

; move up one screen
left    ldx #$b0
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

; subctract x from top left address
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
