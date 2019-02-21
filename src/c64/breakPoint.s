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

.include "magicFlash64Colors.inc"
.include "assembler.inc"
.include "key.inc"

.export breakPoint
breakPoint:
  lda $d020
  pha
  lda #RED
  sta $d020
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  pla
  sta $d020
  rts
