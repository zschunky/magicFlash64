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

.section .recovery,"ax",@progbits
; send one byte via nmi, value expected in tTmp
.global sendByteImpl
sendByteImpl:
  ; disable interrupts
  cli

  ; set counter to 8 bits
  ldi rTmp3,8
5:
  SYNC
4:
  ; wait for read at 0x00
  waitOe rTmp2       ; 0+4
  tst rTmp2          ; 4+1
  dotWait 1          ; 5+1
  brne 4b            ; 6+2/1

  ; shift value and skip if current bit is not set
  lsr rTmp           ; 7+1
  brcc 2f            ; 0+2/1

  ; fire nmi
  cbi NMI_PORT,NMI_P ; 1+2
  sbi NMI_DDR,NMI_P  ; 3+2

  dotWait 3          ; 5+3


  ; wait for read at 0x3f (nmi vector)
3:
  waitOe rTmp2         ; 0+4
  dotWait 1            ; 4+1
  cpi rTmp2,ADDR_MASK  ; 5+1
  brne 3b              ; 6+2/1

  ; clear nmi
  cbi NMI_DDR,NMI_P    ; 7+2
  sbi NMI_PORT,NMI_P   ; 1+2
2:
  ; decrement bit counter and repeat if not yet done
  dec rTmp3
  brne 5b

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


