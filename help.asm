helpScreenStartAddress = $0540

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
        lda #>helpScreenStartAddress
        sta lineStart+1
        lda #<helpScreenStartAddress
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

helpScreen
        BYTE $F0,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C0,$C0,$EE
        BYTE $DD,$15,$10,$AF,$04,$0F,$17,$0E,$A0,$A0,$2B,$AF,$2D,$DD
        BYTE $DD,$0C,$05,$06,$14,$AF,$12,$09,$07,$08,$14,$A0,$A0,$DD
        BYTE $DD,$07,$8F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $DD,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $DD,$11,$95,$89,$94,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $ED,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C0,$C0,$FD

savedScreen
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
