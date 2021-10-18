goScreenLineStart = $0590

goOffsetX = 16
goOffsetY = 10
goScreenWidth = 8
goScreenHeight = 5

;-------------------------------------------------------------------------------
offset  BYTE $0
;-------------------------------------------------------------------------------
go
        jsr setupGo
        jsr drawGo

@wait   jsr GETIN
        beq @wait

        sec
        rts
;-------------------------------------------------------------------------------
setupGo
        lda #goOffsetY
        sta row
        lda #>goScreenLineStart
        sta lineStart+1
        lda #<goScreenLineStart
        sta lineStart

        lda #$00
        sta offset
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
drawGo
        lda #goOffsetX
        sta col

        ldx #goScreenWidth
@loop
        ldy col
        lda (lineStart),y
        ldy offset
        sta savedScreen,y

        lda goScreen,y
        jsr outputChar

        inc offset
        dex
        bne @loop

        jsr moveToNextLine

        lda offset
        cmp #goScreenWidth * goScreenHeight
        bne drawGo

        rts
;-------------------------------------------------------------------------------
