screenRam = $0400

GETIN = $ffe4

DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d
Q_KEY = $51
F1_KEY = $85

col = $d3
row = $d6

numberOfColumns = #$28
numberOfRows = #$1a

; points to start of the line being printed
lineStart = $fb

; points to the address to be loaded
value = $fd

;-------------------------------------------------------------------------------
; 2021 SYS49152
*=$0801
        BYTE $0B, $08, $e5, $07, $9E, $34, $39, $31, $35, $32, $00, $00, $00
;-------------------------------------------------------------------------------

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
resetPosition
        ldy #$00
        sty col
        ldy #$02
        sty row

        lda #>screenRam
        sta lineStart+1
        lda #<screenRam
        clc
        adc numberOfColumns
        adc numberOfColumns
        sta lineStart
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
moveToNextLine
        ldy #$00
        sty col
        inc row
        lda row
        cmp numberOfRows
        bne @next
        
        jsr resetPosition
        jmp @done

@next
        lda numberOfColumns
        clc
        adc lineStart
        sta lineStart
        bcc @done
        
        inc lineStart+1
@done
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; handle input, set carry flag if continuing
handleKeypress
        jsr GETIN
        beq handleKeypress

        cmp #DOWN_ARROW
        beq down

        cmp #UP_ARROW
        beq up

        cmp #RIGHT_ARROW
        beq right

        cmp #LEFT_ARROW
        beq left

        cmp #F1_KEY
        beq showHelpScreen

        cmp #Q_KEY 
        clc
        beq exit

        sec
exit    rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
down    ldx #$08
        jsr moveDown
        sec
        rts

up      ldx #$08
        jsr moveUp
        sec
        rts

right   ldx #$b0
        jsr moveDown
        sec
        rts

left    ldx #$b0
        jsr moveUp
        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
moveDown
        txa
        clc
        adc base
        bcc @skip
        inc base+1
@skip   sta base
        rts

moveUp
        lda base
        stx base
        sec
        sbc base
        bcs @skip
        dec base+1
@skip   sta base
        rts
;-------------------------------------------------------------------------------
