; This demo smoothly reveals a message on the screen by
; pressing any key other than 'q'

*=$C000
      jmp start

VICbase    = $d000
sprtbase   = $0340
getkey     = $ffe4
scnbase    = $0400
colbase    = $d800
bordercl   = $d020
;
start jsr initspt
      jsr initscn
      jsr dispchar

; move the sprite
loop3 lda spritebndy
      cmp #8
      bne skip1
      lda #0
      sta spritebndy
      jsr dispchar
      cmp #0      ; any chars left?
      beq exit
skip1 lda spritexpos
      sta VICbase
      inc spritexpos
      inc spritebndy

; wait for keyboard            
kloop jsr $ff9f
      jsr getkey
      cmp #0
      beq kloop
      cmp #"q"  ;`q` key
      bne loop3
exit  brk

; display the current character
; set acc to zero if no more chars left
dispchar ldx charpos      
      lda msg,x
      cmp #0
      beq exit1
      sta scnbase,x
      inc charpos
      rts
exit1 lda #0
      rts

initscn lda #0 ; black border
      sta bordercl
      sta bordercl+1 ; black background
      rts

; set up the sprite
initspt lda #$1
      sta VICbase+21      ; enable sprite 0
      lda #13
      sta 2040            ; sprite 0 data from block 13
      ldx #0
loop4 lda sprt1,x
      sta sprtbase,x
      inx
      cpx #64
      bne loop4

; sprite color
      lda #0      ; black
      sta VICbase+39
; position the sprite
      lda spritexpos
      sta VICbase
      lda #50
      sta VICbase+1
      lda #0
      sta spritebndy
      rts

; variables
charpos    byte 0
spritexpos byte 24
spritebndy byte 0
;
msg   byte 8,5,12,12,15,44,32,23,15,18,12,4,33,0 ; hello, world!
sprt1 byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 255,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
      byte 0,0,0
