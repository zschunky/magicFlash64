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

#include "config.inc"

.text
cmdSetRam:
  ; get address argument
  waitOe zl
  dotWait 4

  ; get lo nibble data argument
  waitOe rTmp2
  andi rTmp2,0xf
  dotWait 3

  ; get hi nibble data argument
  waitOe
  andi rTmp,0xf
  swap rTmp
  or rTmp,rTmp2

  ; z to ram
  clr zh
  ldi rTmp2,lo8(ram)
  ldi rTmp3,hi8(ram)
  add zl,rTmp2
  adc zh,rTmp3


  st z,rTmp
  rjmp mainLoop


