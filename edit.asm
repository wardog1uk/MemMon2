;-------------------------------------------------------------------------------
showEditScreen
        jsr moveToTopLeftOfScreen
        jsr moveToNextLine
        jsr moveToNextLine

        ldy #$07
        sty col

        jsr invertEditValue

@wait   jsr GETIN
        beq @wait

        sec
        rts
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
