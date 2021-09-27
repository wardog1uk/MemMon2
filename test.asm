PLOT = $fff0
SETCURSOR = $e56C
CHROUT = $ffd2
CLEAR = $e544
GETIN = $ffe4

DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d

scrnram = $0400

col = $d3
row = $d6

; 10 SYS (49152)
*=$0801
        BYTE $0E, $08, $0A, $00, $9E, $20, $28,  $34, $39, $31, $35, $32, $29, $00, $00, $00

*=$c000
        jsr CLEAR

        jsr drawFrame

        lda #$00
        sta base
        lda #$c0
        sta base+1

start   
        jsr resetPosition
        jsr resetValue
        jsr drawScreen
        jsr handleKeypress
        bcs start
        rts


drawFrame
        ldx #250
@loop   lda data-1,x
        sta scrnram-1,x
        lda data+249,x
        sta scrnram+249,x
        lda data+499,x
        sta scrnram+499,x
        lda data+749,x
        sta scrnram+749,x
        dex
        bne @loop
        rts


drawScreen
        jsr drawLine
        jsr moveToNextLine
        ldx row
        cpx #24
        bne drawScreen
        rts


resetPosition
        ldy #1  ; X position
        sty col
        ldx #2  ; Y position
        stx row
        jsr SETCURSOR
        rts


resetValue
        lda base
        sta value
        lda base+1
        sta value+1
        rts


drawLine
        ; output start address
        lda value+1
        jsr outputByte
        lda value
        jsr outputByte

        ; move cursor right
        inc col

        ; move cursor right
loop    inc col

        ; update position
        jsr SETCURSOR

        ; output byte from address
        lda value
        sta $fb
        lda value+1
        sta $fc
        ldy #$0
        lda ($fb),y
        jsr outputByte

        ; increment address
        inc value
        ldy value
        bne @skip
        inc value+1

        ; loop until last byte in row
@skip   ldy col
        cpy #30
        bne loop

        rts


moveToNextLine
        inc row
        ldy #1
        sty col
        jsr SETCURSOR
        rts


; deals with key press, sets X to 0 if exiting, else 1
handleKeypress
        jsr GETIN
        beq handleKeypress
testDown
        cmp #DOWN_ARROW
        bne testUp
        moveDown $08
        sec
        rts
testUp
        cmp #UP_ARROW
        bne testRight
        moveUp $08
        sec
        rts
testRight
        cmp #RIGHT_ARROW
        bne testLeft
        moveDown $b0
        sec
        rts
testLeft
        cmp #LEFT_ARROW
        bne exit
        moveUp $b0
        sec
        rts
exit    
        clc
        rts


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


; print hex value of A to screen at current position
outputByte
        pha
        lsr
        lsr
        lsr
        lsr
        jsr byteToScreen
        jsr CHROUT
        pla
        jsr byteToScreen
        jsr CHROUT
        rts


; convert lowest 4 bits of A to screen code
byteToScreen
        and #$0f
        clc
        adc #$30
        cmp #$3a
        bcc @exit
        clc
        adc #$07
@exit   rts


base    BYTE $00, $c0
value   BYTE $ff, $ff




data    BYTE $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$8D,$85,$8D,$8F,$92,$99,$A0,$8D,$8F,$8E,$89,$94,$8F,$92,$A0,$B2,$B0,$B2,$B1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$86,$B1
        BYTE $4F,$77,$77,$77,$77,$50,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77
        BYTE $74,$30,$33,$33,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$34,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$34,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$35,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$35,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$36,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$36,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$37,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$37,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$38,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$38,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$39,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$39,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$01,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$01,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$02,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$02,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$03,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$03,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$04,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$04,$03,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $74,$30,$33,$05,$34,$67,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$30,$30,$20,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E,$20
        BYTE $4C,$6F,$6F,$6F,$6F,$7A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE $00