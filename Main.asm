; start of screen memory
screenRam = $0400

; initial start address to display
startPosition = $c000

; screen size
screenWidth = #40
screenHeight = #25

; number of bytes and rows displayed
bytesInLine = #8
rowsOnScreen = #22
displayedBytes = bytesInLine * rowsOnScreen

; zero page addresses that hold the current column and row numbers
col = $d3
row = $d6

; points to the address for the start of the current line
lineStart = $fb

; points to the address of memory to be loaded
value = $fd

;-------------------------------------------------------------------------------
*=$c000
start
        lda #<startPosition
        sta base
        sta value
        lda #>startPosition
        sta base+1
        sta value+1

        jsr drawFrame
@mainLoop
        jsr resetPosition
        jsr resetValue
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

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; reset value to top left address
resetValue
        lda base
        sta value
        lda base+1
        sta value+1
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
        lda data+499,xc
        sta screenRam+499,x
        lda data+749,x
        sta screenRam+749,x
        dex
        bne @loop
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
        lda value+1
        jsr printByte
        lda value
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
        lda (value),y
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
        lda (value),y
        jsr outputChar
        inx
        cpx #bytesInLine
        bne @byteLoop

        ;-----------------------------------------------------------------------
        ; move address to next row
        lda #bytesInLine
        clc
        adc value
        sta value
        bcc @done
        inc value+1

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
; convert lowest 4 bits of A to screen code
byteToScreen
        and #$0f
        clc
        adc #$30
        cmp #$3a
        bcc @done
        sec
        sbc #$39
@done   rts
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
; move cursor to the next line
moveToNextLine
        ldy #$00
        sty col

        inc row
        lda row
        cmp screenHeight
        beq @done

        lda screenWidth
        clc
        adc lineStart
        sta lineStart
        bcc @done
        
        inc lineStart+1
@done
        rts
;-------------------------------------------------------------------------------
