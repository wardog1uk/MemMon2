;-------------------------------------------------------------------------------
showHelpScreen
        jsr setupHelp
        jsr drawHelp

@wait   jsr GETIN
        beq @wait

        jsr setupHelp
        jsr undrawHelp

        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
setupHelp
        lda #8
        sta row
        lda #$05
        sta lineStart+1
        lda #$40
        sta lineStart

        lda #$00
        sta pos
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
drawHelp
        lda #13
        sta col
        ldx #14
@loop   jsr readChar
        ldy pos
        sta savedScreen,y
        lda helpScreen,y
        jsr outputChar
        inc pos
        dex
        bne @loop

        jsr moveToNextLine

        lda #98
        cmp pos
        bne drawHelp

        rts

pos     BYTE $0
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
undrawHelp
        lda #13
        sta col
        ldx #14
@loop   ldy pos
        lda savedScreen,y
        jsr outputChar
        inc pos
        dex
        bne @loop

        jsr moveToNextLine

        lda #98
        cmp pos
        bne undrawHelp

        rts
;-------------------------------------------------------------------------------

helpScreen
        BYTE $F0,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C0,$C0,$EE
        BYTE $DD,$15,$10,$AF,$04,$0F,$17,$0E,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $DD,$0C,$05,$06,$14,$AF,$12,$09,$07,$08,$14,$A0,$A0,$DD
        BYTE $DD,$07,$8F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $DD,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $DD,$11,$95,$89,$94,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$DD
        BYTE $ED,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C0,$C0,$FD
        BYTE $00

savedScreen
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
