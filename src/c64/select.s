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
.include "magicFlash64Lib.inc"

;incBegin
.include "key.inc"
.include "assembler.inc"
.include "tick.inc"

; screenItem, inverse, drawItem
.macro select draw, drawSpace, selectedItem, numRows, numValues, keyJmpKey, keyJmpAddr, validCheck
.scope
  lda #<keyTableKey
  sta keyJmpTableKey
  lda #>keyTableKey
  sta keyJmpTableKey+1
  lda #<keyTableLo
  sta keyJmpTableLo
  lda #>keyTableLo
  sta keyJmpTableLo+1
  lda #<keyTableHi
  sta keyJmpTableHi
  lda #>keyTableHi
  sta keyJmpTableHi+1



drawAll:
  lda #(numRows-1)/2
  sta screenItem
  lda selectedItem
  sta drawItem
  cmp numValues
  bcs :+
    lda #$80
    sta inverse
    jsr draw
    lda #0
    sta inverse
    jmp :++
:
  jsr drawSpace
:
    

  dec screenItem
:
  dec drawItem
  bmi :+
.ifnblank validCheck
  ldx drawItem
  jsr validCheck
  bne :-
.endif

  jsr draw
  dec screenItem
  bpl :-

  jmp :++

:
  jsr drawSpace
  dec screenItem
  bpl :-
:

  lda #(numRows-1)/2 + 1
  sta screenItem
  lda selectedItem
  sta drawItem
:
  inc drawItem
  ldx drawItem
  cpx numValues
  bcs :+
.ifnblank validCheck
  jsr validCheck
  bne :-
.endif

  jsr draw
  ldx screenItem
  inx 
  stx screenItem
  cpx #numRows
  bne :-

  rts

:
  jsr drawSpace
  ldx screenItem
  inx 
  stx screenItem
  cpx #numRows
  bne :-
  rts

keyCrsrRelease:
  lda #0
  sta tickPtr
  sta tickPtr+1

tickCrsr:
  dec tickCnt
  beq :+
    rts
:
  lda #10
  sta tickCnt
  jmp :+
  

keyCrsr:
  lda #25
  sta tickCnt

  lda #<tickCrsr
  sta tickPtr
  lda #>tickCrsr
  sta tickPtr+1

:
  jsr isShiftKeyDown
  beq keyCrsrUp

  ldx selectedItem
.ifnblank validCheck
:
.endif
  inx
  cpx numValues
  beq :+
.ifnblank validCheck
  jsr validCheck
  bne :-
.endif

  stx selectedItem

  jsr drawAll
:
  rts
keyCrsrUp:
  ldx selectedItem
.ifnblank validCheck
:
.endif
  dex
  bmi :+
.ifnblank validCheck
  jsr validCheck
  bne :-
.endif

  stx selectedItem

  jsr drawAll
:
  rts
keyTableKey:
  .byte KEY_CRSR_UD, KEY_UP KEY_CRSR_UD               ; crsr
  .byte keyJmpKey
  .byte $ff
keyTableLo:
  .lobytes keyCrsr-1, keyCrsrRelease-1     ; crsr
  .lobytes keyJmpAddr
keyTableHi:
  .hibytes keyCrsr-1, keyCrsrRelease-1     ; crsr
  .hibytes keyJmpAddr


.pushseg
.bss
tickCnt:
  .res 1

.popseg

.endscope
.endmacro

.macro drawTable table, screenLo, screenHi, width
  ldx screenItem
  lda screenLo,x
  sta screenPtr
  lda screenHi,x
  sta screenPtr+1

  lda #<table
  sta srcPtr
  lda #>table
  sta srcPtr+1

  ldy #0
  ldx drawItem
  beq :+++

:
    ; get length of current item
    lda (srcPtr),y

    ; adjust ptr for next item
    sec
    adc srcPtr
    sta srcPtr
    bcc :+
      inc srcPtr+1
:
    dex
    bne :--
:
  lda (srcPtr),y
  sta len

  inc srcPtr
  bne :+
    inc srcPtr+1

:
    lda (srcPtr),y
    eor inverse
    sta (screenPtr),y
    iny
    cpy len
    bne :-

  cpy #width
  beq :++
  lda #$20
  eor inverse
:
    sta (screenPtr),y
    iny
    cpy #width
    bne :-
:
  rts
.endmacro
.macro drawSpace len, screenLo, screenHi
  ldx screenItem
  lda screenLo,x
  sta screenPtr
  lda screenHi,x
  sta screenPtr+1
  lda #$20
  ldy #len-1
:
    sta (screenPtr),y
    dey
    bpl :-
  rts

.endmacro
;incEnd

.zeropage
.exportzp screenItem
screenItem:
  .res 1
.exportzp drawItem
drawItem:
  .res 1
.exportzp inverse
inverse:
  .res 1



