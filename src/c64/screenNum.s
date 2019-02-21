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
.include "zeropage.inc"
.macpack cbm

.export screenNum24
screenNum24:
  pha

  txa
  pha

  tya
  jsr screenNum8

  pla
  jsr screenNum8

  pla
  jmp screenNum8

.export screenNum16
screenNum16:
  pha
  txa

  jsr screenNum8

  pla
.export screenNum8
screenNum8:
  pha
  php

  lsr
  lsr
  lsr
  lsr
 
  plp
  jsr screenNum4
  pla

  and #$0f

.export screenNum4
screenNum4:
  and #$ff
  bne :+

    bcc skip
:
      sec
      tax
      lda num2Screen,x

      ldy #0
      sta (screenPtr),y

      inc screenPtr
      bne skip
        inc screenPtr+1
skip:
  rts

.export screenNum0
screenNum0:
  bcs :+
    lda #48
    sta (screenPtr),y

    inc screenPtr
    bne skip
      inc screenPtr+1
:
  rts


num2Screen:
  scrcode "0123456789ABCDEF"
 
