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
.export plaKernalIoOn
plaKernalIoOn:
  lda $01
  and #$f8
  ora #$06
  sta $01
  rts

.export plaKernalOffIoOn
plaKernalOffIoOn:
  lda $01
  and #$f8
  ora #$05
  sta $01
  rts

.export plaKernalOffIoOff
plaKernalOffIoOff:
  lda $01
  and #$f8
  sta $01
  rts

.export plaInit
plaInit:
  lda #$e7
  sta $01
  lda #$2f
  sta $00
  rts


