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
  ; get address argument
  waitOe rTmp
  mov rTmp10,rTmp

  ; disable LED
  ldi rLed,0x10
  rcall setLed

  mov rTmp4,rTmp10
  andi rTmp4,7

  clr rLoop
cmdTestLoopBegin:
  SYNC
cmdTestLoop:
  ; wait for read at 0x00
  waitOe
  dotWait 1
  tst rTmp 
  brne cmdTestLoop


  mov rTmp3,rLoop
  andi rTmp3,ADDR_MASK

cmdTestRd:
  sbrs rTmp4,0
  rjmp cmdTestWr

  ldi rTmp2,32
  SYNC
cmdTestRdLoop:
  ; loop while OE is low
  waitOe

  cp rTmp3,rTmp
  brne cmdTestFailRd

  ldi rTmp,ADDR_MASK
  eor rTmp3,rTmp

  dec rTmp2
  dotWait 5
  brne cmdTestRdLoop

  
cmdTestWr:
  sbrs rTmp4,1
  rjmp cmdTestRdBck

  ldi rTmp2,32
  SYNC
cmdTestWrLoop:
  waitWr rTmp

  cp rTmp3,rTmp      ; 5
  brne cmdTestFailWr ; 6

  ldi rTmp,ADDR_MASK ; 7
  eor rTmp3,rTmp     ; 8

  dec rTmp2          ; 1
  dotWait 5          ; 6
  brne cmdTestWrLoop ; 8

cmdTestRdBck:
  sbrs rTmp4,2
  rjmp cmdTestCont

  mov rTmp,rLoop
  rcall sendByte

cmdTestCont:
  inc rLoop

  rjmp cmdTestLoopBegin
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
