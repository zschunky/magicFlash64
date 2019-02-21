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
cmdSetDefault:
  ; get argument
  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK

  ; z to eeDefaultSlot
  ldi zh,hi8(eeDefaultSlot)
  ldi zl,lo8(eeDefaultSlot)

  rcall writeEeprom
  rjmp mainLoop

