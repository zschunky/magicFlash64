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
.include "crc.inc"
.include "slot.inc"
.include "magicFlash64Lib.inc"

.export patchTable
patchTable:
  lda slot
  cmp #BOOT_SLOT
  bne patchTableDone

    lda srcPtr
    ldx srcPtr+1
    sta tmp1
    stx tmp2

    ; reset crc for boot slot
    lda #0
    sta slotDescrCrc+BOOT_SLOT
    sta crc

    lda #<slotDescrStart
    sta tmp3
    lda #>slotDescrStart
    sta tmp4
    ldy #0
    ldx #5
    stx len
:
      lda (tmp3),y 
      sta (tmp1),y
      crc8 crc
      iny
      bne :-
      inc tmp2
      inc tmp4
      dec len
      bne :-

    ldx #($20 - 5)
    stx len
:
      lda (tmp1),y 
      crc8 crc
      iny
      bne :-
      inc tmp2
      dec len
      bne :-

    lda srcPtr
    clc
    adc #<(slotDescrCrc-slotDescrStart+BOOT_SLOT)
    sta tmp1
    lda srcPtr+1
    adc #>(slotDescrCrc-slotDescrStart+BOOT_SLOT)
    sta tmp2
    
    lda crc
    sta (tmp1),y
    
patchTableDone:
  rts
