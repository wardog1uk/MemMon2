screenRam = $0400

col = $d3
row = $d6

numberOfColumns = #$28
numberOfRows = #$1a

; points to the address for the start of the current line
lineStart = $fb

; points to the address of memory to be loaded
value = $fd

;-------------------------------------------------------------------------------
*=$c000
        lda #$00
        sta base
        sta value
        lda #$c0
        sta base+1
        sta value+1

        jsr drawFrame
mainLoop
        jsr resetPosition
        jsr resetValue
        jsr drawScreen
        jsr handleKeypress
        bcs mainLoop
        rts

base    BYTE $ff, $ff
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move to first line of data
resetPosition
        lda #<screenRam
        sta lineStart
        lda #>screenRam
        sta lineStart+1

        ldy #$00
        sty row

        jsr moveToNextLine
        jsr moveToNextLine

        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
resetValue
        lda base
        sta value
        lda base+1
        sta value+1
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
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
drawScreen
        jsr drawLine
        jsr moveToNextLine
        ldx row
        cpx #24
        bne drawScreen
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
drawLine
        lda #$01
        sta col

        ; output start address
        lda value+1
        jsr printByte
        lda value
        jsr printByte

        inc col
        
        ldx #$08
        ldy #$00

lineLoop
        inc col

        ; output hex value of byte from address
        lda (value),y
        jsr printByte

        dex
        bne lineLoop

        jsr incrementCursor

        ; output bytes
        ldx #$08
byteLoop
        lda (value),y
        jsr outputChar
        dex
        bne byteLoop

        ; move value to next row
        lda #$08
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
; read byte from current screen position to A
readChar
        ldy col
        lda (lineStart),y
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; move cursor right one place
incrementCursor
        inc col
        lda col
        cmp numberOfColumns
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
        cmp numberOfRows
        beq @done

        lda numberOfColumns
        clc
        adc lineStart
        sta lineStart
        bcc @done
        
        inc lineStart+1
@done
        rts
;-------------------------------------------------------------------------------
