.include "c64.inc"
.include "magicFlash64Colors.inc"
.include "screenNum.inc"
.include "num.inc"
.include "zeropage.inc"
.include "magicFlash64Lib.inc"
.include "screenCpy.inc"
.include "textMenuEn.inc"
.include "selectSlotMenu.inc"

.code
.export menuFrame
menuFrame:
  lda #<slotScreen
  ldx #>slotScreen
  jsr _screenCpy
  lda #<kernalTab
  ldx #>kernalTab
  jsr _screenCpy


  lda #<slotScreenMenuVerPtr
  sta screenPtr
  lda #>slotScreenMenuVerPtr
  sta screenPtr+1

  lda #VER_MENU_MAJOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ldy #0
  lda #46
  sta (screenPtr),y
  inc screenPtr
  bne :+
    inc screenPtr+1
:

  lda #VER_MENU_MINOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0
    
  lda #<slotScreenFwVerPtr
  sta screenPtr
  lda #>slotScreenFwVerPtr
  sta screenPtr+1

  ; get fw version number
  jsr _ekGetVersion
  cmp #$00
  bne :++
    cpx #$00
    bne :++
:
     inc $d020
     jmp :-
:
  tay
  txa
  pha
  tya

  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ldy #0
  lda #46
  sta (screenPtr),y
  inc screenPtr
  bne :+
    inc screenPtr+1
:

  pla
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  lda cart
  bne :+
    lda #<cartNotDetected
    ldx #>cartNotDetected
    jmp :++
:
    lda #<cartDetected
    ldx #>cartDetected
:
  jmp _screenCpy
