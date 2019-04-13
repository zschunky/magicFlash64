; 
; Copyright (c) 2019 Andreas Zschunke
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
; 

.include "c64.inc"
.include "select.inc"
.include "magicFlash64Lib.inc"
.include "zeropage.inc"
.include "textMenuEn.inc"
.include "magicFlash64Colors.inc"
.include "pla.inc"
.include "screenCpy.inc"
.include "injectInt.inc"
.include "qrcode.inc"
.include "menuFrame.inc"



.zeropage
.exportzp slotType
slotType:
  .res 1
.exportzp selectedTab
selectedTab:
  .res 1

.exportzp cart
cart:
  .res 1

.bss
.export tabSelection
tabSelection:
  .res 3

.code
.export slotInit
slotInit:
  lda #$00
  sta selectedTab

  jsr _ekGetDefault
  ;lda #$3f
  sta defaultSlot

  jsr _ekGetPrev
  cmp #$ff
  beq :+
    tax
    jmp :++

:
  ldx #0
:
  lda slotDescrType,x
  cmp #$41
  beq :+
  inx
  cpx #$3f
  bne :-
:  
  stx selectedSlot
  stx tabSelection

  lda #$41
  sta slotType

  ldx #$00
:
  lda slotDescrType,x
  cmp #$42
  beq :+
  inx
  cpx #$40
  bne :-
:  
  stx tabSelection+1

  ldx #$00
:
  lda slotDescrType,x
  cmp #$43
  beq :+
  inx
  cpx #$40
  bne :-
:  
  stx tabSelection+2

  lda #$00
  sta keyNumPos

  ; check for cartridge
  jsr plaKernalIoOn
  ldx $8000
  jsr plaInit
  cpx $8000
  bne :+

  inc $8000

  cpx $8000
  bne :++
:
    lda #1
    sta cart

    lda #<cartFound
    ldx #>cartFound
    jmp _screenCpy

:
  stx $8000

  lda #0
  sta cart

  lda #<noCartFound
  ldx #>noCartFound
  jmp _screenCpy


.export selectSlotMenu
selectSlotMenu:
select drawSlotKernal, drawSlotKernalSpace, selectedSlot, 13, #64, {KEY_RETURN,KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_K,KEY_P,KEY_C,KEY_CRSR_LR,KEY_F1}, {keyReturn-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyK-1,keyP-1,keyC-1,keyLR-1,keyF1-1}, slotCheck


.export drawSlotKernalSpace
drawSlotKernalSpace:
  drawSpace SELECT_LEN,selectSlotScreenLo, selectSlotScreenHi

drawSlotKernalDone:
  rts

drawSlotKernal:
  ldx screenItem
  lda selectSlotScreenLo,x
  sta screenPtr
  lda selectSlotScreenHi,x
  sta screenPtr+1

  jsr drawSlotMenu

  lda selectedTab
  cmp #0
  bne drawSlotKernalDone

  lda inverse
  bpl drawSlotKernalDone

  lda #<slotScreenSelectedKernalPtr
  sta screenPtr
  lda #>slotScreenSelectedKernalPtr
  sta screenPtr+1

  lda #0
  sta inverse

drawSlotMenu:
  ldx drawItem


  ldy #0
  lda slotDigit0,x
  eor inverse
  sta (screenPtr),y

  lda slotDigit1,x
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda #45
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y


  inc screenPtr
  bne :+
  inc screenPtr+1
:
  jsr setSlotNamePtr
  
:
  lda (slotPtr),y
  eor inverse
  sta (screenPtr),y
  iny
  cpy #16
  bne :-

  lda #$20
  eor inverse
:
  sta (screenPtr),y
  iny
  cpy #SELECT_LEN- 3
  bne :-

  ldx screenItem
  lda selectSlotScreenLo,x
  sta screenPtr
  lda selectSlotScreenHi,x
  clc
  adc #$d4
  sta screenPtr+1

  lda #COLOR_SELECTED
  ldx drawItem
  cpx defaultSlot
  beq drawColor
    lda slotDescrType,x
    cmp #$ff
    bne :+
      lda #COLOR_EMPTY
      jmp drawColor
:
    cmp #$40
    bcs :+
      lda #COLOR_FOLLOWUP
      jmp drawColor
:
    sec
    sbc #$40
    tax
    lda colorTypes,x

drawColor:
  ldy #SELECT_LEN- 1
:
    sta (screenPtr),y
    dey
    bpl :-

  rts

.export setTab
setTab:

  ldy selectedTab
  lda selectedSlot
  sta tabSelection,y

  stx selectedTab
  lda tabSelection,x
  sta selectedSlot

  txa
  clc
  adc #$41
  sta slotType

  ldy tabsLo,x
  lda tabsHi,x
  tax
  tya
  jsr _screenCpy

  jmp selectSlotMenu

.export keyK
keyK:
  ldx #0
  jmp setTab

.export keyP
keyP:
  ldx #1
  jmp setTab
  
.export keyC
keyC:
  ldx #2
  jmp setTab
  
  
.export keyNum
keyNum:
  inc keyNumPos

  lda keyLast
  jsr getNumKey
  cpy #10
  bne :+++
:
    lda #1
    sta keyNumPos
:
    rts
:
  lda keyNumPos
  cmp #2
  bne :--


  tya
  asl a
  sta tmp1
  asl a
  asl a
  clc
  adc tmp1
  sta tmp1
  
  txa
  jsr getNumKey
  tya
  clc
  adc tmp1

  cmp #64
  bcs :---

  tax
  jsr slotCheck
  bne :---
  
  stx selectedSlot

  lda #0
  sta keyNumPos

  jmp selectSlotMenu



getNumKey:
  ldy #0
:
  cmp numberKeys,y
  beq :+
  iny
  cpy #10
  bne :-
:
  rts

.export keyF1
keyF1:
  lda #<helpFrame
  ldx #>helpFrame
  jsr _screenCpy

  lda #<help1
  ldx #>help1
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help2
  ldx #>help2
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help3
  ldx #>help3
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help4
  ldx #>help4
  jsr _screenCpy
  ldx #14
:
  .repeat 15,i
     lda qrcode +i*15,x
     sta $0400+20+(i+4)*40,x
  .endrepeat
     dex
     bpl :-


:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  jsr menuFrame
  jmp selectSlotMenu

.export setSlotNamePtr
setSlotNamePtr:
  lda slotDescrNameAddrLo,x
  sta slotPtr
  lda slotDescrNameAddrHi,x
  sta slotPtr+1
  rts

.export slotCheck
slotCheck:
  lda slotType
  bmi :+
  cmp slotDescrType,x
  rts
:
  lda #0
  rts


.export keyLR
keyLR:
  
  jsr isShiftKeyDown
  beq keyL

  ldx selectedTab
  inx
  cpx #3
  bne :+
    ldx #0
:
  jmp setTab
  

keyL:
  ldx selectedTab
  dex
  bpl :+
    ldx #2
:
  jmp setTab

.data
.export keyNumPos
keyNumPos:
  .byte 0


.code
numberKeys:
  .byte 35; 0
  .byte 56; 1
  .byte 59; 2
  .byte 8 ; 3
  .byte 11; 4
  .byte 16; 5
  .byte 19; 6
  .byte 24; 7
  .byte 27; 8
  .byte 32; 9
  
slotDescrNameAddrLo:
  .repeat 64,i
    .lobytes slotDescrName+i*16
  .endrepeat
slotDescrNameAddrHi:
  .repeat 64,i
    .hibytes slotDescrName+i*16
  .endrepeat

.segment "DATA2"
.export keyReturn
keyReturn:
  ldy selectedTab
  cpy #0
  beq :++
    ldx selectedSlot
    
    cpy #1
    bne :+
      stx injectSlot
:
    lda tabSelection
    sta injectKernal
    jmp :++
:
  lda selectedSlot
:
  jsr _ekSelect

  lda selectedTab
  cmp #0
  beq :++
    lda cart
    bne :+
      lda #BOOT_SLOT
      ldx #8
      jsr _ekSelectAfterInt
      jmp :++
:
    lda #BOOT_SLOT
    jsr _ekSelectAfterRestoreInt

:
      lda $d012
      cmp #$4c
      bne :-
:
      lda $d012
      cmp #$4d
      bne :-
    lda $d011
    bmi :-
  
  ldx #$ff
  txs

  jmp ($fffc)


.code
.export slotDigit0
slotDigit0:  
  .byte 48,48,48,48,48,48,48,48,48,48
  .byte 49,49,49,49,49,49,49,49,49,49
  .byte 50,50,50,50,50,50,50,50,50,50
  .byte 51,51,51,51,51,51,51,51,51,51
  .byte 52,52,52,52,52,52,52,52,52,52
  .byte 53,53,53,53,53,53,53,53,53,53
  .byte 54,54,54,54
.export slotDigit1
slotDigit1:  
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51
selectSlotScreenLo:
  .repeat 17,i
    .lobytes $0400+(i+10)*40+9
  .endrepeat
selectSlotScreenHi:
  .repeat 17,i
    .hibytes $0400+(i+10)*40+9
  .endrepeat

.export tabsLo
tabsLo:
  .lobytes kernalTab, prgTab, cartTab
.export tabsHi
tabsHi:
  .hibytes kernalTab, prgTab, cartTab
colorTypes:
  .byte COLOR_BASIC, COLOR_KERNAL, COLOR_PRG, COLOR_CART, COLOR_MENU

.segment "SLOT_TABLE"
.export slotDescrStart
slotDescrStart:
.export slotDescrType
slotDescrType:
  .res 64
.export slotDescrCrc
slotDescrCrc:
  .res 64
.export slotDescrSizeLo
slotDescrSizeLo:
  .res 64
.export slotDescrSizeHi
slotDescrSizeHi:
  .res 64
.export slotDescrName
slotDescrName:
  .res 64 * 16
slotDescrEnd:
