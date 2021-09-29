screenRam = $0400

GETIN = $ffe4

DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d
Q_KEY = $51

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
        ldx #$00
        stx col
        ldx #$02
        stx row

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
        ldx #$00

lineLoop
        inc col

        ; output hex value of byte from address
        txa
        tay
        lda (value),y
        jsr printByte

        inx
        cpx #$08
        bne lineLoop

        jsr incrementCursor

        ; output bytes
        ldx #$00
byteLoop
        txa
        tay
        lda (value),y
        jsr outputChar
        inx
        cpx #$08
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
        ldx #$00
        stx col
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
testDown
        cmp #DOWN_ARROW
        bne testUp
        moveDown $08
        jmp exit
testUp
        cmp #UP_ARROW
        bne testRight
        moveUp $08
        jmp exit
testRight
        cmp #RIGHT_ARROW
        bne testLeft
        moveDown $b0
        jmp exit
testLeft
        cmp #LEFT_ARROW
        bne testQ
        moveUp $b0
        jmp exit
testQ
        cmp #Q_KEY 
        bne exit
        clc
        rts
exit    
        sec
        rts
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
defm    moveDown
        lda base
        clc
        adc #/1
        bcc @skip
        inc base+1
@skip   sta base
        endm

defm    moveUp
        lda base
        sec
        sbc #/1
        bcs @skip
        dec base+1
@skip   sta base
        endm
;-------------------------------------------------------------------------------

data    BYTE $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$8D,$85,$8D,$8F,$92,$99,$A0,$8D,$8F,$8E,$89,$94,$8F,$92,$A0,$B2,$B0,$B2,$B1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$86,$B1
        BYTE $4F,$77,$77,$77,$77,$50,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$20,$20,$20,$20,$67,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $4C,$6F,$6F,$6F,$6F,$7A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE $00
