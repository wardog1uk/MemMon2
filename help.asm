helpScreenLineStart = $0540

helpOffsetX = 13
helpOffsetY = 8
helpScreenWidth = 14
helpScreenHeight = 7

offset  BYTE $0
;-------------------------------------------------------------------------------
showHelpScreen
        jsr setupHelp
        jsr drawHelp

@wait   jsr GETIN
        beq @wait

        jsr setupHelp
        jsr restoreScreen

        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
setupHelp
        lda #helpOffsetY
        sta row
        lda #>helpScreenLineStart
        sta lineStart+1
        lda #<helpScreenLineStart
        sta lineStart

        lda #$00
        sta offset
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
drawHelp
        lda #helpOffsetX
        sta col

        ldx #helpScreenWidth
@loop
        ldy col
        lda (lineStart),y
        ldy offset
        sta savedScreen,y

        lda helpScreen,y
        jsr outputChar

        inc offset
        dex
        bne @loop

        jsr moveToNextLine

        lda offset
        cmp #helpScreenWidth * helpScreenHeight
        bne drawHelp

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
restoreScreen
        lda #helpOffsetX
        sta col

        ldx #helpScreenWidth
@loop
        ldy offset
        lda savedScreen,y
        jsr outputChar

        inc offset
        dex
        bne @loop

        jsr moveToNextLine

        lda offset
        cmp #helpScreenWidth * helpScreenHeight
        bne restoreScreen

        rts
;-------------------------------------------------------------------------------
