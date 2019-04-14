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
waitInt:
  ; no interrupts from now on
  cli

  ; set prev and select
  mov rPrev,rSelect
  mov rSelect,rTmp

  setSelPrep
  ; wait for 3 writes in a row (brk opcode)

#ifdef M20
pollWr:
    waitWr
    wait 18

    sbic RW_PIN,RW_P
    rjmp pollWr

    wait 18

    sbic RW_PIN,RW_P
    rjmp pollWr

    dec rTmp10
    brne pollWr
#endif
#ifdef DOT
  SYNC
  dotWait 5
  dec rTmp10
  breq pollWr2
  dotWait 1

pollWr:
    waitWr rTmp3
    dotWait 5  ; 4+5

    in rTmp3,RW_PIN ; 1+1
    dotWait 3       ; 2+3
    sbrc rTmp3,RW_P ; 5+1
    rjmp pollWr     ; 6+2/1


    dotWait 2       ; 7+2

    in rTmp3,RW_PIN ; 1+1
    dotWait 3       ; 2+3
    sbrc rTmp3,RW_P ; 5+1
    rjmp pollWr     ; 6+2/1

    dec rTmp10      ; 7+1
    brne pollCont   ; 0+2/1

    dotWait 7

pollWr2:
    waitWr rTmp3
    dotWait 5  ; 4+5

    in rTmp3,RW_PIN ; 1+1
    dotWait 3       ; 2+3
    sbrc rTmp3,RW_P ; 5+1
    rjmp pollWr2     ; 6+2/1


    dotWait 2       ; 7+2

    in rTmp3,RW_PIN ; 1+1
    dotWait 3       ; 2+3
    sbrc rTmp3,RW_P ; 5+1
    rjmp pollWr2     ; 6+2/1
#endif
  setSelExec

  ret

#ifdef DOT
pollCont:
  dotWait 4      ; 2+4
  rjmp pollWr    ; 4+2
#endif
