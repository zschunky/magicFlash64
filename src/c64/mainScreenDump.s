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


.segment "LOADADDR"
.export __LOADADDR__
__LOADADDR__:
.lobytes $0801
.hibytes $0801

.segment "EXEHDR"
.byte $0B, $08, $F0, $02, $9E, $32, $30, $36, $31, $00, $00, $00


.define screenPtr $fe
.define colorPtr $fc
.define targetPtr $fa

.macro inc16 addr
.scope
  inc addr
  bne l
    inc addr+1
l:
.endscope
.endmacro

.bss
oldNmi:
  .res 2
lastColor:
  .res 0

.segment "STARTUP"
.export __STARTUP__
__STARTUP__:
  sei

  lda $0318
  sta oldNmi
  lda $0319
  sta oldNmi+1

  lda #<nmi
  sta $0318
  lda #>nmi
  sta $0319

  lda #$ff
  sta lastColor


  cli
  rts

nmiDone:
  jmp (oldNmi)
nmi:
  lda #$00
  tax
:
  sta $c000,x
  sta $c100,x
  sta $c200,x
  sta $c300,x
  inx
  bne :-

  lda #$00
  sta colorPtr
  sta screenPtr
  sta targetPtr
  lda #$04
  sta screenPtr+1
  lda #$d8
  sta colorPtr+1
  lda #$c0
  sta targetPtr+1

loop:
  lda screenPtr+1
  cmp #$08
  beq nmiDone


  ldy #0
  lda (screenPtr),y

  cmp #$80
  bne :+
    sta (targetPtr),y
    jmp nmiDone

:
  iny
  cpy #$6f
  beq :+
  cmp (screenPtr),y
  beq :-

:
  cpy #1
  beq singleChar

  cpy #2
  beq singleChar

  tya
  tax
  clc
  adc #$80


  ldy #0
  sta (targetPtr),y

  inc16 targetPtr
  lda (screenPtr),y
  sta (targetPtr),y

  inc targetPtr
  bne :+
    inc targetPtr+1
:
  txa
  clc
  adc screenPtr
  sta screenPtr
  sta colorPtr
  bcc loop
  inc screenPtr+1
  inc colorPtr+1
  jmp loop

singleChar:
  tya
  tax

  ldy #0
singleCharLoop:
  lda (screenPtr),y
  cmp #32
  beq :+
    lda (colorPtr),y
    and #$0f
    cmp lastColor
    beq :+
      sta lastColor
      clc
      adc #$f0
      sta (targetPtr),y
      inc16 targetPtr
:
  lda (screenPtr),y
  sta (targetPtr),y
  inc16 targetPtr
  inc16 screenPtr
  inc16 colorPtr

  dex
  bne singleCharLoop
  jmp loop
  

    



  
