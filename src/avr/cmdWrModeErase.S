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
cmdWrModeErase:
#ifdef M20
  sbrc rSel13Old,0
  rjmp cmdWrModeEraseOld
#endif

  sbi SEL13NEW_DDR,SEL13NEW_P  ; 0+2
  cbi SEL14_DDR,SEL14_P        ; 2+2

#ifdef DOT
  ; enable writes to flash from now on
  cbi WE_PORT,WE_P             ; 4+2
#endif
  dotWait 2                    ; 6+2
  waitWr                       ; 0 +4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif

  cbi SEL13NEW_DDR,SEL13NEW_P  ; 4+2
  sbi SEL14_DDR,SEL14_P        ; 6+2
  waitWr                       ; 0+4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif

  sbi SEL13NEW_DDR,SEL13NEW_P  ; 4+2
  cbi SEL14_DDR,SEL14_P        ; 6+2
  waitWr                       ; 0+4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif
  dotWait 4                    ; 4+4

  waitWr                       ; 0+4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif

  cbi SEL13NEW_DDR,SEL13NEW_P ; 4+2
  sbi SEL14_DDR,SEL14_P       ; 6+2
  waitWr                      ; 0+4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif

  rcall setSelect             ; 4+(2+2)
  waitWr                      ; 0+4

#ifdef M20
  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P
#endif

#ifdef DOT
  ; disable writes to flash
  sbi WE_PORT,WE_P            ; 4+2
#endif
  rjmp mainLoop               ; 6+2

#ifdef M20
cmdWrModeEraseOld:
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

  rcall setSelect
  waitWr

  ; toggle we
  cbi WE_PORT,WE_P
  sbi WE_PORT,WE_P

  rjmp mainLoop
#endif
