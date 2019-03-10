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
setLed:

  ; stop timer
  ldi rTmp,0
  sts TCCR1B,rTmp
  sts TCCR1A,rTmp
  sts TCNT1H,rTmp
  sts TCNT1L,rTmp


  mov rTmp,rLed
  andi rTmp,7
  breq setLedOnOff

    ; check for top full vs half
    sbrc rLed,3
    rjmp setLedFull
      ldi zl,lo8(lookupLedHalf)
      ldi zh,hi8(lookupLedHalf)
      ldi rTmp4,hi8(LED_HALF_CNT-1)
      ldi rTmp5,lo8(LED_HALF_CNT-1)
    rjmp setLedCont

setLedFull:
      ldi zl,lo8(lookupLedFull)
      ldi zh,hi8(lookupLedFull)
      ldi rTmp4,hi8(LED_FULL_CNT-1)
      ldi rTmp5,lo8(LED_FULL_CNT-1)

setLedCont:

    lsl rTmp
    add zl,rTmp

    ld rTmp6,z+
    ld rTmp2,z

    ; assemble TCCR1A
    ldi rTmp3,(2<<COM1A0)|(2<<WGM10)

    ; set prescaler
    mov rTmp,rLed
    swap rTmp
    andi rTmp,0x3
    inc rTmp
    inc rTmp

    ori rTmp,3<<WGM12
    sts OCR1AH,rTmp2
    sts OCR1AL,rTmp6
    sts TCCR1A,rTmp3
    sts TCCR1B,rTmp
    sts ICR1H,rTmp4
    sts ICR1L,rTmp5

    ret
setLedOnOff:
  sbrc rLed,3
  sbi LED_PORT,LED_P
  sbrs rLed,3
  cbi LED_PORT,LED_P
  ret

