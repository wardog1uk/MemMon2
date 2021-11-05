editOffsetX
        BYTE $00

editOffsetY
        BYTE $00

;-------------------------------------------------------------------------------
showEditScreen
        jsr moveToTopLeftOfScreen
        jsr moveToNextLine
        jsr moveToNextLine

        ldy #$00
        sty editOffsetX
        sty editOffsetY

        ldy #$07
        sty col

        jsr invertEditValue

        jsr handleEditInput

        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
handleEditInput
@input  jsr GETIN
        beq @input

        cmp #UP_ARROW
        beq editMoveUp

        cmp #DOWN_ARROW
        beq editMoveDown

        cmp #LEFT_ARROW
        beq editMoveLeft

        cmp #RIGHT_ARROW
        beq editMoveRight

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
editMoveUp
        ldy editOffsetY
        beq @skip

        dey
        sty editOffsetY

        ldx col
        ldy col
        jsr invertEditValue

        ; move to previous line
        dec row
        lda lineStart
        sec
        sbc screenWidth
        sta lineStart
        bcs @next
        dec lineStart+1

@next   stx col
        ldy col
        jsr invertEditValue

@skip   jmp handleEditInput
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
editMoveDown
        ldy editOffsetY
        iny
        cpy rowsOnScreen
        beq @skip

        sty editOffsetY

        ldx col
        ldy col
        jsr invertEditValue

        jsr moveToNextLine

        stx col
        ldy col
        jsr invertEditValue

@skip   jmp handleEditInput
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
editMoveLeft
        ldy editOffsetX
        beq @skip

        dey
        sty editOffsetX

        ldy col
        jsr invertEditValue

        dey
        dey
        dey
        dey
        sty col
        jsr invertEditValue

@skip   jmp handleEditInput
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
editMoveRight
        ldy editOffsetX
        iny
        cpy bytesInLine
        beq @skip

        sty editOffsetX

        ldy col
        jsr invertEditValue

        iny
        iny
        sty col
        jsr invertEditValue

@skip   jmp handleEditInput
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; invert characters at (linestart),y and (linestart),y+1
invertEditValue
        lda (lineStart),y
        clc
        adc #$80
        sta (lineStart),y

        iny
        lda (lineStart),y
        clc
        adc #$80
        sta (lineStart),y

        rts
;-------------------------------------------------------------------------------
