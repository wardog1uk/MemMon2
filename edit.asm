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

        cmp #LEFT_ARROW
        beq editMoveLeft

        cmp #RIGHT_ARROW
        beq editMoveRight

        rts
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
editMoveLeft
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
