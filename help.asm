helpScreenLineStart = screenRam + helpOffsetY * screenWidth

helpOffsetX = 13
helpOffsetY = 9
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
        jsr hideHelpWindow

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
        ; save current byte
        ldy col
        lda (lineStart),y
        ldy offset
        sta savedScreen,y

        ; output help byte
        lda helpScreen,y
        jsr outputChar

        inc offset

        ; check if finished line
        dex
        bne @loop

        jsr moveToNextLine

        ; check if finished drawing window
        lda offset
        cmp #helpScreenWidth * helpScreenHeight
        bne drawHelp

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
hideHelpWindow
        lda #helpOffsetX
        sta col

        ldx #helpScreenWidth
@loop
        ; output saved byte
        ldy offset
        lda savedScreen,y
        jsr outputChar

        inc offset

        ; check if finished line
        dex
        bne @loop

        jsr moveToNextLine

        ; check if finished restoring screen
        lda offset
        cmp #helpScreenWidth * helpScreenHeight
        bne hideHelpWindow

        rts
;-------------------------------------------------------------------------------
