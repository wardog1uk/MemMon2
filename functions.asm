col = $d3
row = $d6
numberOfColumns = #$28
numberOfRows = #$1a
screenRam = $0400

lineStart = $fb

*=$c000
        jsr resetPosition

        lda #$08
        jsr outputChar
        lda #$09
        jsr outputChar

        rts


resetPosition
        ldx #$00
        stx col
        inx
        stx row

        lda #>screenRam
        sta lineStart+1
        lda #<screenRam
        sta lineStart
        rts


; output character from A to current position
outputChar
        ldy col
        sta (lineStart),y
        jsr incrementCursor
        rts


; move cursor right one place
incrementCursor
        inc col
        lda col
        cmp numberOfColumns
        bne @done

        ldx #$00
        stx col
        inc row
        lda row
        cmp numberOfRows
        bne @next
        
        jsr resetPosition
        jmp @done

@next
        lda numberOfColumns
        clc
        adc lineStart
        sta lineStart
        bcc @done
        
        inc lineStart+1
@done
        rts
