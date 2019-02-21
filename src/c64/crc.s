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

.code

;incBegin
.macro crc8 crc,reg
  .if (.blank(reg)) .or (.match({reg}, x))
    eor crc
    tax
    lda crcTab,x
    sta crc
  .else
    eor crc
    tay
    lda crcTab,y
    sta crc
  .endif
.endmacro
;incEnd

.macro crcPolCalc count,value
  .if count = 0
    .byte value
  .else
    .if (value & $80) = 0
      crcPolCalc (count - 1), (value << 1) & 255
    .else
      crcPolCalc (count - 1), ((value << 1) ^ 7) & 255
    .endif
  .endif
.endmacro

.export crcTab
crcTab:
  .repeat 256,i
    crcPolCalc 8,i
  .endrepeat
