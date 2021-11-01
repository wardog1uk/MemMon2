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

        cmp #E_KEY
        beq jumpToEdit

        cmp #Q_KEY
        clc
        beq exit

        sec
exit    rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
jumpToEdit
        jmp showEditScreen

jumpToGo
        jmp showGoScreen

jumpToHelp
        jmp showHelpScreen
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move down one row
down    moveForward #bytesInLine

; move up one row
up      moveBack #bytesInLine

; move down one screen
right   moveForward #displayedBytes

; move up one screen
left    moveBack #displayedBytes

; move forward one byte
plus    moveForward #1

; move back one byte
minus   moveBack #1
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
defm moveForward
        ldx #/1
        jsr moveBaseForward
        sec
        rts
        endm

defm moveBack
        ldx #/1
        jsr moveBaseBack
        sec
        rts
        endm
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; add x to address displayed at the top left
moveBaseForward
        txa
        clc
        adc base
        bcc @skip
        inc base+1
@skip   sta base
        rts

; subtract x from address displayed at the top left
moveBaseBack
        lda base
        stx base
        sec
        sbc base
        bcs @skip
        dec base+1
@skip   sta base
        rts
;-------------------------------------------------------------------------------
