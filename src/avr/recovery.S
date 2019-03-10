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

.section .recoveryLookup,"ax",@progbits
recovery:
  rjmp recoveryImpl
cmdFwUpd:
  rjmp cmdFwUpdImpl
setSelect:
  rjmp setSelectImpl
sendByte:
  rjmp sendByteImpl
getRecoveryVersion:
  ldi rTmp,VER_RECOVERY
  ret


.section .recovery,"ax",@progbits
recoveryImpl:
  ; configure IOs
  sbi WE_PORT,WE_P
  sbi WE_DDR,WE_P
  sbi LED_DDR,LED_P
  sbi RW_PORT,RW_P
  sbi RESTORE_PORT,RESTORE_P
  sbi RESET_PORT,RESET_P
  sbi OE_PORT,OE_P

  ; check for sel13 connection (check for fuse if reset is disabled)
  ldi zl,3
  ldi zh,0
  ldi rTmp,(1<<SPMEN)|(1<<BLBSET)
  out SPMCSR,rTmp
  lpm
  ldi rTmp,0
  sbrs r0,7
  ldi rTmp,1
  mov rSel13Old,rTmp

  ; select backup slot 55
  ldi rSelect,55
  rcall setSelectImpl

  ; set led to blinking
  ldi rTmp4,hi8(LED_FULL_CNT-1)
  ldi rTmp5,lo8(LED_FULL_CNT-1)


  ldi rTmp,lo8(9765)
  ldi rTmp2,hi8(9765)

  ; assemble TCCR1A
  ldi rTmp3,(2<<COM1A0)|(2<<WGM10)

  ; set prescaler
  sts OCR1AH,rTmp2
  sts OCR1AL,rTmp
  sts TCCR1A,rTmp3
  ldi rTmp,4|3<<WGM12
  sts TCCR1B,rTmp
  sts ICR1H,rTmp4
  sts ICR1L,rTmp5

  ; loop for commands
recoveryLoop:
  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
recoveryLoop0:
  cpi rTmp,0
  brne recoveryLoop

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x2a
  brne recoveryLoop0

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x15
  brne recoveryLoop0

  waitOe
  in rTmp,ADDR_PIN
  andi rTmp,ADDR_MASK
  cpi rTmp,0x3f
  brne recoveryLoop0

  ; get command
  waitOe
  in rCmd,ADDR_PIN
  andi rCmd,CMD_MASK

  cpi rCmd,4
  breq cmdSelectRecovery

  cpi rCmd,44
  breq cmdGetModeRecovery

  cpi rCmd,46
  breq cmdGetRecoveryVersionRecovery

  cpi rCmd,12
  brne recoveryLoop

  cbi LED_PORT,LED_P
  rjmp cmdFwUpdImpl
    
  ; S E L E C T   S L O T
cmdSelectRecovery:
  ; get argument
  waitOe
  in rSelect,ADDR_PIN
  andi rSelect,ADDR_MASK

  ; apply selected slot
  rcall setSelectImpl

  ; done, back to recoveryloop
  rjmp recoveryLoop

cmdGetModeRecovery:
  ldi rTmp,1
  rcall sendByte
  rjmp recoveryLoop

cmdGetRecoveryVersionRecovery:
  ldi rTmp,VER_RECOVERY
  rcall sendByte
  rjmp recoveryLoop

