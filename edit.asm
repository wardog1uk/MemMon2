editOffsetX
        BYTE $00

editOffsetY
        BYTE $00

;-------------------------------------------------------------------------------
showEditScreen
        jsr moveToTopLeftOfScreen
        jsr moveToNextLine
        jsr moveToNextLine

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

        cmp #RIGHT_ARROW
        beq editMoveRight

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
editMoveRight
        ldy editOffsetX
        iny
        cpy bytesInLine
        beq @skip

        sty editOffsetX

@skip   jmp handleEditInput
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; invert characters at (linestart),y and (linestart),y+1
invertEditValue
        lda (lineStart),y
        adc #$80
        sta (lineStart),y

        iny
        lda (lineStart),y
        adc #$80
        sta (lineStart),y

        rts
;-------------------------------------------------------------------------------
