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
cmdSelectAfterInt:
  ; reset rLed
  ldi rLed,0
  rcall setLed

  ; get ignoreCount argument
  waitOe
  in rTmp2,ADDR_PIN
  andi rTmp2,ADDR_MASK
  inc rTmp2

  ; get slot argument
  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK

  ; wait for 3 writes in a row (brk opcode)
2:
    waitWr

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    sbic RW_PIN,RW_P
    rjmp 2b

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    sbic RW_PIN,RW_P
    rjmp 2b

    dec rTmp2
    brne 2b

  ; set prev and select
  mov rPrev,rSelect
  mov rSelect,rTmp

  rcall setSelect

  ; reset rLed
  ldi rLed,8
  rcall setLed

  ; done, back to mainLoop
  rjmp mainLoop

