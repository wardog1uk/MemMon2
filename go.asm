goScreenLineStart = screenRam + goOffsetY * screenWidth

goOffsetX = 16
goOffsetY = 10
goScreenWidth = 8
goScreenHeight = 5

;-------------------------------------------------------------------------------
showGoScreen
        jsr setupGo
        jsr drawGo

        jsr handleGoInput

        jsr setupGo
        jsr hideGoWindow

        sec
        rts
;-------------------------------------------------------------------------------

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

        jsr drawGoValue

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; draw current base value
drawGoValue
        jsr setupGo
        jsr moveToNextLine
        jsr moveToNextLine
        
        ldx #goOffsetX
        inx
        inx
        stx col

        lda base+1
        jsr printByte
        lda base
        jsr printByte

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
hideGoWindow
        lda #goOffsetX
        sta col

        ldx #goScreenWidth
@loop
        ldy offset
        lda savedScreen,y
        jsr outputChar

        inc offset
        dex
        bne @loop

        jsr moveToNextLine

        lda offset
        cmp #goScreenWidth * goScreenHeight
        bne hideGoWindow

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
handleGoInput
        jsr GETIN
        beq handleGoInput
        rts
;-------------------------------------------------------------------------------
