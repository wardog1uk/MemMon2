;-------------------------------------------------------------------------------
*=$c000
start
        jsr setup
        jsr drawFrame
@mainLoop
        jsr resetPosition
        jsr drawScreen
        jsr handleKeypress
        bcs @mainLoop

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; address for the byte at the top left of the screen
base    BYTE $00, $00
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
setup
        lda #<startPosition
        sta base
        sta memoryPointer
        lda #>startPosition
        sta base+1
        sta memoryPointer+1
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; draw the screen frame
drawFrame
        ldx #250
@loop   lda data-1,x
        sta screenRam-1,x
        lda data+249,x
        sta screenRam+249,x
        lda data+499,x
        sta screenRam+499,x
        lda data+749,x
        sta screenRam+749,x
        dex
        bne @loop
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move to first line of data
resetPosition
        lda #<screenRam
        sta lineStart
        lda #>screenRam
        sta lineStart+1

        lda #$00
        sta row

        jsr moveToNextLine
        jsr moveToNextLine

        lda base
        sta memoryPointer
        lda base+1
        sta memoryPointer+1

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; output all the screen values
drawScreen
        jsr drawLine
        jsr moveToNextLine
        ldx row
        cpx #rowsOnScreen+2
        bne drawScreen
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; output the current line
drawLine
        lda #$01
        sta col

        ;-----------------------------------------------------------------------
        ; output start address
        lda memoryPointer+1
        jsr printByte
        lda memoryPointer
        jsr printByte

        inc col

        ;-----------------------------------------------------------------------
        ; output values
        ldx #$00
@lineLoop
        inc col
        txa
        tay

        ; output hex value of byte from address
        lda (memoryPointer),y
        jsr printByte

        inx
        cpx #bytesInLine
        bne @lineLoop

        jsr incrementCursor

        ;-----------------------------------------------------------------------
        ; output bytes
        ldx #$00
@byteLoop
        txa
        tay
        lda (memoryPointer),y
        jsr outputChar
        inx
        cpx #bytesInLine
        bne @byteLoop

@done   rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; print hex value of A to screen at current position
printByte
        pha
        lsr
        lsr
        lsr
        lsr
        jsr byteToScreen
        jsr outputChar
        pla
        jsr byteToScreen
        jsr outputChar
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; output byte from A to current screen position
outputChar
        ldy col
        sta (lineStart),y
        jsr incrementCursor
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move cursor right one place
incrementCursor
        inc col
        lda col
        cmp screenWidth
        bne @done
        jsr moveToNextLine
@done   rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
moveToNextLine
        ; check for end of screen
        ldy row
        iny
        cpy screenHeight
        beq @done

        ; increment row
        sty row

        ; set column position to 0
        ldy #$00
        sty col

        ; update start of line
        lda lineStart
        clc
        adc screenWidth
        sta lineStart
        bcc @skip
        inc lineStart+1

@skip   ; move pointer to next row
        lda memoryPointer
        clc
        adc #bytesInLine
        sta memoryPointer
        bcc @done
        inc memoryPointer+1

@done   rts
;-------------------------------------------------------------------------------
