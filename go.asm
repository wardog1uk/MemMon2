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
        ldx #$04

        lda (lineStart),y
        adc #$80
        sta (lineStart),y

@loop
        ; store x on stack
        txa
        pha

        ; wait for input
@input  jsr GETIN
        beq @input

        ; restore x
        tay
        pla
        tax
        tya

        ; check 0-9
        sec
        sbc #$30
        cmp #10
        bcc @done

        ; check A-F
        sbc #$11
        cmp #6
        bcs @loop
        adc #10

@done
        ; A is 0-15
        jsr byteToScreen
        jsr outputChar

        ldy col
        lda (lineStart),y
        adc #$80
        sta (lineStart),y

        dex
        bne @loop

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; retrieve address from screen and save it to base address
saveGoInput
        ldy #goValueOffsetX
        lda (lineStart),y
        jsr screenToByte
        asl
        asl
        asl
        asl
        sta base+1

        iny
        lda (lineStart),y
        jsr screenToByte
        clc
        adc base+1
        sta base+1

        iny
        lda (lineStart),y
        jsr screenToByte
        asl
        asl
        asl
        asl
        sta base

        iny
        lda (lineStart),y
        jsr screenToByte
        clc
        adc base
        sta base

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; convert A from screen code to its value
; A must be '0'-'9' or 'A'-'F'
screenToByte
        clc
        adc #$09
        cmp #$10
        bcc @done
        sbc #$39
@done   rts
;-------------------------------------------------------------------------------
