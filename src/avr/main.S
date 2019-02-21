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
.global __data_start
.global __data_load_start
.global __data_load_end
.global main
main:
  ; configure IOs
  sbi WE_PORT,WE_P
  sbi WE_DDR,WE_P
  sbi LED_DDR,LED_P
  sbi RW_PORT,RW_P
  sbi RESTORE_PORT,RESTORE_P
  sbi RESET_PORT,RESET_P
  sbi OE_PORT,OE_P

  ; set constant registers
  ldi rLookup,lo8(lookup)
  ldi rSel1418Mask,SEL14_18_MASK

  ; set select slot
  ldi zh,hi8(eeDefaultSlot)
  ldi zl,lo8(eeDefaultSlot)

  ; select default
  rcall readEeprom
  andi rTmp,0x3f
  mov rSelect,rTmp
  rcall setSelect

  ; reset prev and rRestoreSelect
  ldi rTmp,0xff
  mov rPrev,rTmp
  mov rRestoreSelect,rTmp

  ; configure timer0, overflow at 625Hz
  ldi rTmp,124
  out OCR0A,rTmp
  ldi rTmp,2<<WGM00
  out TCCR0A,rTmp
  ldi rTmp,4<<CS00
  out TCCR0B,rTmp

  ; copy lookup table from flash into ram
  ldi rTmp4,lo8(__data_load_end)
  ldi rTmp5,hi8(__data_load_end)
  ldi zl,lo8(__data_load_start)
  ldi zh,hi8(__data_load_start)
  ldi xl,lo8(__data_start)
  ldi xh,hi8(__data_start)
copyLoop:
    lpm rTmp,Z+
    st X+,rTmp
    cp zl,rTmp4
    cpc zh,rTmp5
    brne copyLoop

  ; reset rLed
  ldi rLed,8
  rcall setLed

  ; enable restore key interrupt
  ldi rTmp,2<<ISC00
  sts EICRA,rTmp
  sbi EIMSK,INT0

  ; enable reset interrupt
  ldi rTmp,1<<RESET_INT
  sts RESET_INTMSK,rTmp
  ldi rTmp,1<<RESET_IE
  sts PCICR,rTmp

mainBegin:
  cli
  ; clear pending interrupts
  sbi EIFR,INTF0
  sbi PCIFR,RESET_IE
  
  ldi rTmp,hi8(__stack)
  out SPH,rTmp
  ldi rTmp,lo8(__stack)
  out SPL,rTmp
  sei

  ; M A I N L O O P
mainLoop:
  ; check for magic sequence
  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
mainLoop0:
  cpi rTmp,0
  brne mainLoop

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x2a
  brne mainLoop0

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x15
  brne mainLoop0

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x3f
  brne mainLoop0

  ; get command
  waitOe
  in rCmd,ADDR_PIN
  andi rCmd,CMD_MASK

  ; get cmd-func-ptr from lookup and jump to it
  add rCmd,rLookup
  ld zl,x+
  ld zh,x
  ijmp

cmdNop:
  rjmp mainLoop




