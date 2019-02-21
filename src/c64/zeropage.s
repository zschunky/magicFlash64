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


.zeropage
.exportzp tmp1
tmp1:
  .res 1
.exportzp tmp2
tmp2:
  .res 1
.exportzp tmp3
tmp3:
  .res 1
.exportzp tmp4
tmp4:
  .res 1
.exportzp tmp5
tmp5:
  .res 1
.exportzp tmp6
tmp6:
  .res 1
.exportzp tmp7
tmp7:
.res 1
.exportzp tmp8
tmp8:
.res 1
.exportzp size
size:
  .res 2
.exportzp crc
crc:
  .res 1
.exportzp slot
slot:
  .res 1
.exportzp slotTmp
slotTmp:
  .res 1
.exportzp activeKernalSlot
activeKernalSlot:
  .res 1
.exportzp defaultSlot
defaultSlot:
  .res 1
.exportzp srcPtr
srcPtr:
  .res 2
.exportzp slotPtr
slotPtr:
  .res 2
.exportzp selectedSlot
selectedSlot:
  .res 1
.exportzp len
len:
  .res 1
.exportzp screenPtr
screenPtr:
  .res 2
.exportzp eraseBlock
eraseBlock:
  .res 1

