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
;.org 0xeba,0xff
.global __vectors
.global cmdFwUpdImpl
cmdFwUpdImpl:
  cli
  ; setup start address 
  ldi yl,lo8(__vectors)
  ldi yh,hi8(__vectors)

  ; set pagesize
  ldi xl,lo8(SPM_PAGESIZE)
  ldi xh,hi8(SPM_PAGESIZE)

  ; set total max of pages
  ldi rTmp4,lo8((0x1000-FW_ADDR)/SPM_PAGESIZE)
flashLoop:
  ldi rTmp3,lo8(SPM_PAGESIZE/2)
  movw _z,_y

flashBufferLoop:
#if DOT
  push zh
  push zl
#endif
  SYNC
  waitOe              ; 0+4
  cpi rTmp,ADDR_MASK  ; 4+1
  breq flashDone      ; 5+2/1
  mov r0,rTmp         ; 6+1
  dotWait 1           ; 7+1

  waitOe rTmp2        ; 0+4
  cpi rTmp2,ADDR_MASK ; 4+1
  breq flashDone      ; 5+2/1

  swap rTmp2          ; 6+1
  or r0,rTmp2         ; 7+1

  waitOe              ; 0+4
  cpi rTmp,ADDR_MASK  ; 4+1
  breq flashDone      ; 5+2/1
  mov r1,rTmp         ; 6+1
  dotWait 1           ; 7+1

  waitOe rTmp2        ; 0+4
  cpi rTmp2,ADDR_MASK ; 4+1
  breq flashDone      ; 5+2/1
  swap rTmp2          ; 6+1
  or r1,rTmp2         ; 7+1

#if DOT
  pop zl
  pop zh
#endif

  ldi rTmp2,(1<<SPMEN) 
  out SPMCSR,rTmp2

  spm

  adiw _z,2
  dec rTmp3
  brne flashBufferLoop

  rcall flashErasePgm

  ; adjust y
  add yl,xl
  adc yh,xh
  rjmp flashLoop

flashDone:
#if DOT
  pop zl
  pop zh
#endif

  cpi rTmp3,SPM_PAGESIZE/2
  breq flashExit
  rcall flashErasePgm
flashExit:
  rjmp boot

flashErasePgm:
  movw _z,_y

  ; make sure only text is being written
  tst rTmp4
  breq flashSkip
  dec rTmp4


  ; erase page
  ldi rTmp2,(1<<PGERS)|(1<<SPMEN)
  out SPMCSR,rTmp2
  spm

  ; program page
  ldi rTmp2,(1<<PGWRT)|(1<<SPMEN)
  out SPMCSR,rTmp2
  spm
flashSkip:
  ret

