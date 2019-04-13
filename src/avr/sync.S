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
syncInitImpl:
  ldi rTmp,7
  sts OCR2A,rTmp
  ldi rTmp,2<<WGM20
  sts TCCR2A,rTmp
  ldi rTmp,1<<CS20
  sts TCCR2B,rTmp

  clr rTmp10

resync:
  in rTmp2,PHI2_PIN
  in rTmp3,PHI2_PIN
  in rTmp4,PHI2_PIN
  in rTmp5,PHI2_PIN
  in rTmp6,PHI2_PIN
  in rTmp7,PHI2_PIN
  in rTmp8,PHI2_PIN
  in rTmp9,PHI2_PIN

  bst rTmp2,PHI2_P
  bld rTmp,0
  bst rTmp3,PHI2_P
  bld rTmp,1
  bst rTmp4,PHI2_P
  bld rTmp,2
  bst rTmp5,PHI2_P
  bld rTmp,3
  bst rTmp6,PHI2_P
  bld rTmp,4 
  bst rTmp7,PHI2_P
  bld rTmp,5
  bst rTmp8,PHI2_P
  bld rTmp,6
  bst rTmp9,PHI2_P
  bld rTmp,7

  
  cp rTmp,rTmp10
  mov rTmp10,rTmp
  nop
  nop
  nop
  nop
  brne resync
  nop

  cpi rTmp,SYNC_PHI2 ; 0
  breq sync5         ; 1/2 -> 7-2-0=5

  bst rTmp,7         ; 2
  lsl rTmp           ; 3
  bld rTmp,0         ; 4
  cpi rTmp,SYNC_PHI2 ; 5
  breq sync7         ; 6/7 -> 7-7-1=7

  bst rTmp,7         ; 7
  lsl rTmp           ; 0
  bld rTmp,0         ; 1
  cpi rTmp,SYNC_PHI2 ; 2
  breq sync1         ; 3/4 -> 7-4-2=1

  bst rTmp,7         ; 4
  lsl rTmp           ; 5
  bld rTmp,0         ; 6
  cpi rTmp,SYNC_PHI2 ; 7
  breq sync3         ; 0/1 -> 7-1-3=3

  bst rTmp,7         ; 1
  lsl rTmp           ; 2
  bld rTmp,0         ; 3
  cpi rTmp,SYNC_PHI2 ; 4
  breq sync5         ; 5/6 -> 7-6-4=5

  bst rTmp,7         ; 6
  lsl rTmp           ; 7
  bld rTmp,0         ; 0
  cpi rTmp,SYNC_PHI2 ; 1
  breq sync7         ; 2/3 -> 7-3-5=7

  bst rTmp,7         ; 3
  lsl rTmp           ; 4
  bld rTmp,0         ; 5
  cpi rTmp,SYNC_PHI2 ; 6
  breq sync1         ; 7/0 -> 7-0-6=1

  bst rTmp,7         ; 0
  lsl rTmp           ; 1
  bld rTmp,0         ; 2
  cpi rTmp,SYNC_PHI2 ; 3
  breq sync3         ; 4/5 -> 7-5-7=3

  ; error, no sync found

  clr rTmp10
  rjmp resync
  
sync7:
  nop
sync6:
  nop
sync5:
  nop
sync4:
  nop
sync3:
  nop
sync2:
  nop
sync1:
  nop
sync0:
  
  sts TCNT2,r00
  ret

;nop
;nop
;nop
;
;
;  rcall sync
;
;  ldi rTmp,0
;  ldi rTmp2,1<<GPIO_P
;  nop
;  nop
;  nop
;  nop
;  nop
;  nop
;
;loop:
;    out GPIO_PORT,rTmp
;    out GPIO_PORT,rTmp2
;    nop
;    nop
;    nop
;    nop
;    rjmp loop

;    sbic RW_PIN,RW_P
;    rjmp loopNoRw
;    
;    out GPIO_DDR,rTmp2
;    nop
;    nop
;    out GPIO_DDR,rTmp
;    rjmp loop
;loopNoRw:
;    nop
;    nop
;    out GPIO_DDR,rTmp
;    rjmp loop



syncImpl:
  lds zl,TCNT2
  ldi zh,hi8(pm(syncJmp))
  ori zl,lo8(pm(syncJmp))
  ijmp

.align 4
syncJmp:
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  ret

  


;oeLoop:
;  cpi rTmp,0
;  breq oeNext
;    rjmp oeLoop
;
;oeNext:
;  nop
;
;
;
;
