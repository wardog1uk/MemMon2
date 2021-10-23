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

        cmp #PLUS_KEY
        beq plus

        cmp #MINUS_KEY
        beq minus

        cmp #F1_KEY
        beq jumpToHelp

        cmp #G_KEY
        beq jumpToGo

        cmp #Q_KEY
        clc
        beq exit

        sec
exit    rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
jumpToGo
        jmp showGoScreen

jumpToHelp
        jmp showHelpScreen
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move down one row
down    ldx #bytesInLine
        jsr moveForward
        sec
        rts

; move up one row
up      ldx #bytesInLine
        jsr moveBack
        sec
        rts

; move down one screen
right   ldx #displayedBytes
        jsr moveForward
        sec
        rts

; move up one screen
left    ldx #displayedBytes
        jsr moveBack
        sec
        rts

; move forward one byte
plus    ldx #1
        jsr moveForward
        sec
        rts

; move back one byte
minus   ldx #1
        jsr moveBack
        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; add x to address displayed at the top left
moveForward
        txa
        clc
        adc base
        bcc @skip
        inc base+1
@skip   sta base
        rts

; subtract x from address displayed at the top left
moveBack
        lda base
        stx base
        sec
        sbc base
        bcs @skip
        dec base+1
@skip   sta base
        rts
;-------------------------------------------------------------------------------
