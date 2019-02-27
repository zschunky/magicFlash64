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
.include "assembler.inc"
.include "zeropage.inc"

;incBegin
.define KEY_DEL 0
.define KEY_RETURN 1
.define KEY_CRSR_LR 2
.define KEY_F7 3
.define KEY_F1 4
.define KEY_F3 5
.define KEY_F5 6
.define KEY_CRSR_UD 7
.define KEY_3 8
.define KEY_W 9
.define KEY_A 10
.define KEY_4 11
.define KEY_Z 12
.define KEY_S 13
.define KEY_E 14
.define KEY_SHIFT_L 15
.define KEY_5 16
.define KEY_R 17
.define KEY_D 18
.define KEY_6 19
.define KEY_C 20
.define KEY_F 21
.define KEY_T 22
.define KEY_X 23
.define KEY_7 24
.define KEY_Y 25
.define KEY_G 26
.define KEY_8 27
.define KEY_B 28
.define KEY_H 29
.define KEY_U 30
.define KEY_V 31
.define KEY_9 32
.define KEY_I 33
.define KEY_J 34
.define KEY_0 35
.define KEY_M 36
.define KEY_K 37
.define KEY_O 38
.define KEY_N 39
.define KEY_PLUS 40
.define KEY_P 41
.define KEY_L 42
.define KEY_MINUS 43
.define KEY_DOT 44
.define KEY_COLON 45
.define KEY_AT 46
.define KEY_COMMA 47
.define KEY_POUND 48
.define KEY_ASTERIX 49
.define KEY_SEMICOLON 50
.define KEY_HOME 51
.define KEY_SHIFT_R 52
.define KEY_EQUAL 53
.define KEY_PTR_U 54
.define KEY_SLASH 55
.define KEY_1 56
.define KEY_PTR_L 57
.define KEY_CTRL 58
.define KEY_2 59
.define KEY_SPACE 60
.define KEY_CBM 61
.define KEY_Q 62
.define KEY_STOP 63

.define KEY_ALL $80
.define KEY_UP(key) key|$40
.define KEY_END $ff


.define KEY2MASK(key) 1<<(key & 7)|(1<<((key>>3)+8))^$ff00
;incEnd

.zeropage
.exportzp _keyMap
_keyMap:
  .res 8
keyMapPrev:
  .res 8
.exportzp keyJmpTableKey
keyJmpTableKey:
  .res 2
.exportzp keyJmpTableLo
keyJmpTableLo:
  .res 2
.exportzp keyJmpTableHi
keyJmpTableHi:
  .res 2
key:
  .res 1
keyMask:
  .res 1
keyPrev:
  .res 1
keyPressed:
  .res 1


.data
.export keyLast
keyLast:
  .res 1,255

.code
.export _initKeys
_initKeys:
   lda #$ff
   ldx #7
:
   sta _keyMap,x
   sta keyMapPrev,x
   dex
   bpl :-
   rts

.export _getKeys
_getKeys:
   ldx #$00
   stx CIA1_DDRB
   dex 
   stx CIA1_DDRA
   lda #$fe
   ldx #0
:
   sta CIA1_PRA
:
   ldy CIA1_PRB
   cpy CIA1_PRB
   bne :-
   sty _keyMap,x
   inx
   sec
   rol
   bcs :--
   rts
.export isKeyDown
isKeyDown:
   ldy #$00
   sty CIA1_DDRB
   dey 
   sty CIA1_DDRA

   stx CIA1_PRA
   and CIA1_PRB
   rts

.export isShiftKeyDown
isShiftKeyDown:
  ldax #KEY2MASK KEY_SHIFT_L 
  jsr isKeyDown
  beq :+

  ldax #KEY2MASK KEY_SHIFT_R 
  jmp isKeyDown
:
  rts

.export _isKeyDown
_isKeyDown:
   tay
   lsr
   lsr
   lsr
   tax
   tya
   and #7
   tay

   lda #$00
   sec
:
   rol
   clc
   dey
   bpl :-

   and _keyMap,x
   beq :+
   lda #0
   rts
:
   lda #1
   rts

.export _evalKey
_evalKey:
   ldx #$00
   stx CIA1_DDRB
   dex 
   stx CIA1_DDRA
   lda #$fe
   sta keyMask
   inx
:
   sta CIA1_PRA
:
   ldy CIA1_PRB
   cpy CIA1_PRB
   bne :-
   sty _keyMap,x
   inx
   sec
   rol
   bcs :--

   ldx #0
   ldy #0
:
   lda keyMapPrev,x
   sta keyPrev

   lda keyMask
   sta CIA1_PRA
:
   lda CIA1_PRB
   cmp CIA1_PRB
   bne :-
   sta keyPressed
   sta keyMapPrev,x

   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit
   jsr evalKeyBit

   inx
   sec
   rol keyMask
   bcs :--
   rts


evalKeyBit:
   lda #0

   ror keyPressed
   bcc :+
   ora #1
:
   ror keyPrev
   bcc :+
   ora #2
:
   cmp #1
   bne :+
   txa
   pha
   tya
   pha
;.import _keyDown
   jsr _keyUp
   pla
   tay
   pla
   tax
   iny
   rts

:
   cmp #2
   bne :+
   txa
   pha
   tya
   pha
;.import _keyUp
   jsr _keyDown
   pla
   tay
   pla
   tax
   sty keyLast
:
   iny
   rts

.export _keyUp
_keyUp:
   ora #KEY_UP 0
   ldy #KEY_UP KEY_ALL
   sty tmp1
   bne :+
.export _keyDown
_keyDown:
;   lda #$2a
;   sta $0400,y
;   rts
   ldy #KEY_ALL
   sty tmp1
:
   sta key
   tax
   ldy #0
:
   lda (keyJmpTableKey),y
   cmp key
   beq :+
   cmp tmp1
   beq :+
   iny
   cmp #KEY_END
   bne :-
   rts
:
   lda (keyJmpTableHi),y
   pha
   lda (keyJmpTableLo),y
   pha
   rts
