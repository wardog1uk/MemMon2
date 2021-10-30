goScreenLineStart = screenRam + goOffsetY * screenWidth

goOffsetX = 16
goOffsetY = 10

goValueOffsetX = goOffsetX + 2

goScreenWidth = 8
goScreenHeight = 5

;-------------------------------------------------------------------------------
showGoScreen
        jsr setupGo
        jsr drawGo

        jsr handleGoInput
        jsr saveGoInput

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
        
        ldx #goValueOffsetX
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
        ldy #goValueOffsetX
        sty col
        jsr invertGoCursor

        ; set up loop
        ldx #$04
        stx goPosition
@loop
        ; wait for input
@input  jsr GETIN
        beq @input

        ; if space then use current value
        cmp #SPACE_KEY
        bne @skip

        ldy col
        jsr invertGoCursor

        ; check if not A-F
        cmp #7
        bcs @skip

        ; convert character's screen code back to petscii
        clc
        adc #$40

@skip
        sec
        sbc #$30

        ; check if 0-9
        cmp #10
        bcc @done

        sbc #$11

        ; restart loop if not A-F
        cmp #6
        bcs @loop

        adc #10

@done
        ; A is 0-15
        jsr byteToScreen
        jsr outputChar

        ldy col
        jsr invertGoCursor

        dec goPosition
        ldx goPosition
        bne @loop

        rts

goPosition
        BYTE $00
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
invertGoCursor
        lda (lineStart),y
        clc
        adc #$80
        sta (lineStart),y
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; retrieve address from screen and save it to base address
saveGoInput
        ldy #goValueOffsetX
        saveHighByteTo base+1
        saveLowByteTo base+1
        saveHighByteTo base
        saveLowByteTo base
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
defm saveHighByteTo
        lda (lineStart),y
        jsr screenToByte
        asl
        asl
        asl
        asl
        sta /1
        iny
        endm

defm saveLowByteTo
        lda (lineStart),y
        jsr screenToByte
        clc
        adc /1
        sta /1
        iny
        endm
;-------------------------------------------------------------------------------
