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
reset:
  cli

  ; remove pull up
  cbi RESET_PORT,RESET_P

  ; pull reset low
  sbi RESET_DDR,RESET_P

  ; small delay
  clr rTmp
  clr rTmp2
1:
  dec rTmp
  brne 1b
  dec rTmp2
  brne 1b

  ; release reset
  cbi RESET_DDR,RESET_P
  
  ; activate pull up
  sbi RESET_PORT,RESET_P

  ret

.global RESET_VECT 
RESET_VECT:
; c64 reset vector
  sbic RESET_PIN,RESET_P
  rjmp mainBegin

  ; remember led status
  push rLed

  ; disable led
  ldi rLed,0x10
  rcall setLed

  ; repeat ~2 seconds
  ldi rTmp4,lo8(2*625)
  ldi rTmp5,hi8(2*625)
  sbi TIFR0,OCF0A
1:
  sbic RESET_PIN,RESET_P
  rjmp resetDone

  sbis TIFR0,OCF0A
  rjmp 1b

  sbi TIFR0,OCF0A

  sbiw rTmp4,1
  brne 1b

  ; set led blinking
  ldi rLed,0x24
  rcall setLed

  ; remember current slot
  mov rPrev,rSelect

  ; set boot slot
  ldi rSelect,0x3f
  rcall setSelect


  ; wait for reset release
1:
  sbis RESET_PIN,RESET_P
  rjmp 1b

resetDone:
  ; reset led
  pop rLed
  rcall setLed

  rjmp mainBegin

