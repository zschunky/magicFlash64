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
; send one byte via nmi, value expected in tTmp
sendByte:
  ; disable interrupts
  cli

  ; set counter to 8 bits
  ldi rTmp3,8
4:
  ; wait for read at 0x00
  waitOe
  in rTmp2,ADDR_PIN
  andi rTmp2,ADDR_MASK
  brne 4b

  ; shift value and skip if current bit is not set
  lsr rTmp
  brcc 2f

  ; fire nmi
  cbi NMI_PORT,NMI_P
  sbi NMI_DDR,NMI_P

  ; wait for read at 0x3f (nmi vector)
3:
  waitOe
  in rTmp2,ADDR_PIN
  andi rTmp2,ADDR_MASK
  cpi rTmp2,ADDR_MASK
  brne 3b

  ; clear nmi
  cbi NMI_DDR,NMI_P
  sbi NMI_PORT,NMI_P
2:
  ; decrement bit counter and repeat if not yet done
  dec rTmp3
  brne 4b

;  ; make sure nmi is high
;1:
;  ldi rTmp,16
;2:
;  sbis NMI_PIN,NMI_P
;  rjmp 1b
;  dec rTmp
;  brne 2b


  ; done, back to mainLoop
  ret


