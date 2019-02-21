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

.include "magicFlash64.inc"
.include "magicFlash64Lib.inc"
.include "assembler.inc"
.include "zeropage.inc"
.include "selectSlotMenu.inc"
.include "c64.inc"

.code

.import __INJECT_RAM_SIZE__
.import __INJECT_RAM_RUN__
.import __INJECT_RAM_LOAD__

.export injectInt
injectInt:
  ldx #0
:
  lda __INJECT_RAM_LOAD__,x
  sta __INJECT_RAM_RUN__,x
  inx
  cpx #<__INJECT_RAM_SIZE__
  bne :-
 
  push injectKernal, srcPtr, srcPtr+1, slotPtr, slotPtr+1, size, size+1, slot,slotTmp

  lda injectSlot
  sta slotTmp
  tax
  stx slot
  jsr setSrc
  jsr setSize
  txa
  jsr setSlot
  inc16 srcPtr
  inc16 srcPtr
  dec16 size
  dec16 size

  ; check for start address $0801
  lda slotPtr
  cmp #$01
  bne :++
  lda slotPtr+1
  cmp #$08
  bne :++
    ; write run\n into keyboard buffer
    ldx #3
  :
    lda runCmd,x
    sta $0277,x
    dex
    bpl :-

    ; set keyboard buffer len to 4
    lda #4
    sta $c6
:
  ldx slot
  jmp :+
injectSlotLoop:
    stx slot

    jsr setSrc
    jsr setSize
:
    txa
    jsr injectCopy

    ldx slot
    lda slotTmp
:
      inx
      cpx #64
      beq :+

      cmp slotDescrType,x
      bne :-
    jmp injectSlotLoop
:



  pop slotTmp, slot, size+1, size, slotPtr+1, slotPtr, srcPtr+1, srcPtr
  pla
  jmp exitInjectInt

.export setSrc
setSrc:
  lda #$00
  sta srcPtr
  lda #$e0
  sta srcPtr+1
  rts


.export setSize
setSize:
  lda slotDescrSizeHi,x
  cmp #$20
  bcs :+
    sta size+1
    lda slotDescrSizeLo,x
    sta size
    rts
:
  lda #0
  sta size
  lda #$20
  sta size+1
  rts


.export runCmd
runCmd:
  .byte "run",13

.segment "INJECT_RAM"
.export exitInjectInt
exitInjectInt:
  jsr noBadInject
  SEQ CMD_SELECT
  jsr injectStepA

  pla
  tay
  pla
  tax
  pla
  rti

.export setSlot
setSlot:
  jsr noBadInject
  SEQ CMD_SELECT
  jsr injectStepA
  
  ldy #0
  lda (srcPtr),y
  sta slotPtr
  iny
  lda (srcPtr),y
  sta slotPtr+1

  jsr noBadInject
  SEQ CMD_SELECT_PREV
  rts

.export injectCopy
injectCopy:
  jsr noBadInject
  SEQ CMD_SELECT
  jsr injectStepA

  ldy #0
injectCopyLoop:
    lda (srcPtr),y
    sta (slotPtr),y

    inc16 srcPtr
    inc16 slotPtr
    dec16Branch size,injectCopyLoop

  jsr noBadInject
  SEQ CMD_SELECT_PREV
  rts
.export noBadInject
noBadInject:
  NO_BAD
  rts
.export injectStepA
injectStepA:
  STEPA
  rts







.segment "INJECT_PAR"
.export injectSlot
injectSlot:
  .res 1
.export injectKernal
injectKernal:
  .res 1

