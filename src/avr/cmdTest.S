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
cmdTest:
  ; disable LED
  ldi rLed,0x10
  rcall setLed

  ; get address argument
  waitOe
  in rTmp4,ADDR_PIN
  andi rTmp4,7

  clr rLoop
cmdTestLoop:
  ; wait for read at 0x00
  waitOe
  in rTmp2,ADDR_PIN
  andi rTmp2,ADDR_MASK
  brne cmdTestLoop

  mov rTmp3,rLoop
  andi rTmp3,ADDR_MASK

cmdTestRd:
  sbrs rTmp4,0
  rjmp cmdTestWr

  ldi rTmp2,32
cmdTestRdLoop:
  ; loop while OE is low
  waitOe

  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK

  cp rTmp3,rTmp
  brne cmdTestFailRd

  ldi rTmp,ADDR_MASK
  eor rTmp3,rTmp

  dec rTmp2
  brne cmdTestRdLoop

  
cmdTestWr:
  sbrs rTmp4,1
  rjmp cmdTestRdBck

  ldi rTmp2,32
cmdTestWrLoop:
  waitWr

  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK

  cp rTmp3,rTmp
  brne cmdTestFailWr

  ldi rTmp,ADDR_MASK
  eor rTmp3,rTmp

  dec rTmp2
  brne cmdTestWrLoop

cmdTestRdBck:
  sbrs rTmp4,2
  rjmp cmdTestCont

  mov rTmp,rLoop
  rcall sendByte

cmdTestCont:
  inc rLoop

  rjmp cmdTestLoop
cmdTestFailRd:
  ldi rLed,0x18
  rcall setLed
  sei
1:
  rjmp 1b
cmdTestFailWr:
  ldi rLed,0x24
  rcall setLed
  sei
1:
  rjmp 1b
