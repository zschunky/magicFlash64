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
; restore key interrupt
.global INT0_vect  
INT0_vect:
  ; check if slot change is requested
  ldi rTmp,0xff
  cp rRestoreSelect,rTmp
  breq 3f
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

    ; select new slot
    mov rPrev,rSelect
    mov rSelect,rRestoreSelect
    mov rRestoreSelect,rTmp
    rcall setSelect

    ; back to main
    rjmp mainBegin

3:
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
  sbic RESTORE_PIN,RESTORE_P
  rjmp restoreNone

  sbis TIFR0,OCF0A
  rjmp 1b

  sbi TIFR0,OCF0A

  sbiw rTmp4,1
  brne 1b

  ; set led on
  ldi rLed,0x18
  rcall setLed

  ; repeat ~2 seconds
  ldi rTmp4,lo8(2*625)
  ldi rTmp5,hi8(2*625)
  sbi TIFR0,OCF0A
1:
  sbic RESTORE_PIN,RESTORE_P
  rjmp restoreReset

  sbis TIFR0,OCF0A
  rjmp 1b

  sbi TIFR0,OCF0A

  sbiw rTmp4,1
  brne 1b

  ; set led blinking
  ldi rLed,0x24
  rcall setLed

  ; repeat ~2 seconds
  ldi rTmp4,lo8(2*625)
  ldi rTmp5,hi8(2*625)
  sbi TIFR0,OCF0A
1:
  sbic RESTORE_PIN,RESTORE_P
  rjmp restoreBoot

  sbis TIFR0,OCF0A
  rjmp 1b

  sbi TIFR0,OCF0A

  sbiw rTmp4,1
  brne 1b

  ; disable led
  ldi rLed,0x10
  rcall setLed

  ; wait till restore is released
1:
  sbis RESTORE_PIN,RESTORE_P
  rjmp 1b

  rjmp restoreNone

restoreBoot:
  cpi rSelect,0x3f
  breq restoreReset
    mov rPrev,rSelect
    ldi rSelect,0x3f
    rcall setSelect
restoreReset:
  rcall reset
restoreNone:
  ; restore led
  pop rLed
  rcall setLed

  rjmp mainBegin
