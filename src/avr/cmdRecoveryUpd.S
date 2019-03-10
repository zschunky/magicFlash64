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
;.org 0xeba,0xff
.global __vectors
cmdRecoveryUpdate:
  cli
  ; setup start address 
  ldi yl,lo8(recovery)
  ldi yh,hi8(recovery)

  ; set pagesize
  ldi xl,lo8(SPM_PAGESIZE)
  ldi xh,hi8(SPM_PAGESIZE)
  ldi rTmp,ADDR_MASK


  ; set total max of pages
  ldi rTmp4,lo8((FW_ADDR-RECOVERY_ADDR)/SPM_PAGESIZE)
flashLoop:
  ldi rTmp3,lo8(SPM_PAGESIZE/2)
  movw _z,_y

flashBufferLoop:
  waitOe
  in r0,ADDR_PIN
  and r0,rTmp

  cp r0,rTmp
  breq flashDone

  waitOe
  in rTmp2,ADDR_PIN
  and rTmp2,rTmp

  cp rTmp2,rTmp
  breq flashDone
  
  swap rTmp2
  or r0,rTmp2

  waitOe
  in r1,ADDR_PIN
  and r1,rTmp

  cp r1,rTmp
  breq flashDone

  waitOe
  in rTmp2,ADDR_PIN
  and rTmp2,rTmp

  cp rTmp2,rTmp
  breq flashDone
  
  swap rTmp2
  or r1,rTmp2

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
  cpi rTmp3,SPM_PAGESIZE/2
  breq flashExit
  rcall flashErasePgm
flashExit:
  .global __vectors
  rjmp __vectors

flashErasePgm:
  movw _z,_y

  ; make sure only recovery is being written
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

