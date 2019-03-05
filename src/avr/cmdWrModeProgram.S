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
cmdWrModeProgram:
  sbrc rSel13Old,0
  rjmp cmdWrModeProgramOld

  sbi SEL13NEW_DDR,SEL13NEW_P
  cbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  cbi SEL13NEW_DDR,SEL13NEW_P
  sbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  sbi SEL13NEW_DDR,SEL13NEW_P
  cbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  rcall setSelect
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  rjmp mainLoop

cmdWrModeProgramOld:
  sbi SEL13OLD_DDR,SEL13OLD_P
  cbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  cbi SEL13OLD_DDR,SEL13OLD_P
  sbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  sbi SEL13OLD_DDR,SEL13OLD_P
  cbi SEL14_DDR,SEL14_P
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  rcall setSelect
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  rjmp mainLoop

