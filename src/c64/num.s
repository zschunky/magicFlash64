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

.include "zeropage.inc"
.include "slot.inc"

.code
.export num8toDec8
num8toDec8:
  sed
  sta tmp1
  lda #0
  sta tmp2
  ldx #8
:
  asl tmp1
  lda tmp2
  adc tmp2
  sta tmp2
  dex
  bne :-
  cld
  lda tmp2
  rts
.export num8toDec16
num8toDec16:
  sed
  sta tmp1
  lda #0
  sta tmp2
  sta tmp3
  ldx #8
:
  asl tmp1
  lda tmp2
  adc tmp2
  sta tmp2
  lda tmp3
  adc tmp3
  sta tmp3
  dex
  bne :-
  cld
  lda tmp2
  ldx tmp3
  rts

.export num16toDec16
num16toDec16:
  sed
  sta tmp1
  stx tmp2
  lda #0
  sta tmp3
  sta tmp4
  ldx #16
:
  asl tmp1
  rol tmp2
  lda tmp3
  adc tmp3
  sta tmp3
  lda tmp4
  adc tmp4
  sta tmp4
  dex
  bne :-
  cld
  lda tmp3
  ldx tmp4
  rts

.export num16toDec24
num16toDec24:
  sed
  sta tmp1
  stx tmp2
  lda #0
  sta tmp3
  sta tmp4
  sta tmp5
  ldx #16
:
  asl tmp1
  rol tmp2
  lda tmp3
  adc tmp3
  sta tmp3
  lda tmp4
  adc tmp4
  sta tmp4
  lda tmp5
  adc tmp5
  sta tmp5
  dex
  bne :-
  cld
  lda tmp3
  ldx tmp4
  ldy tmp5
  rts

