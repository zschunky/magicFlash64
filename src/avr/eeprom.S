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

.section .eeprom
eeUserData:
.skip 64
eeDefaultSlot:
.skip 1


.text
writeEeprom:
  ; Wait for completion of previous write
  sbic EECR,EEPE
  rjmp writeEeprom

  ; Set up address (z) in address register
  out EEARH, zh
  out EEARL, zl

  ; Write data (rTmp) to Data Register
  out EEDR,rTmp
  ; Write logical one to EEMPE
  sbi EECR,EEMPE
  ; Start eeprom write by setting EEPE
  sbi EECR,EEPE
  ret

readEeprom:
  ; Wait for completion of previous write
  sbic EECR,EEPE
  rjmp readEeprom

  ; Set up address (r18:r17) in address register
  out EEARH, zh
  out EEARL, zl

  ; Start eeprom read by writing EERE
  sbi EECR,EERE

  ; Read data from Data Register
  in rTmp,EEDR
  ret

