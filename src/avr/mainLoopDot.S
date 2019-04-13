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

  ; M A I N L O O P
mainLoop:
  SYNC
cmdNop:
mainLoopInSync:
  ; check for magic sequence of 1st value and restart counter2
  waitOe

  dotWait 1
  cpi rTmp,0
  brne mainLoopInSync
  ldi rTmp2,4

  ; check for magic sequence of 2nd value and restart counter2
mainLoop2a:
1:
  in rTmp,ADDR_PIN
  sbis OE_PIN,OE_P
    rjmp 1f
  dec rTmp2
  breq mainLoop2Exit
  nop
  rjmp 1b
mainLoop2Exit:
  rjmp mainLoopInSync
1:
  cpi rTmp,0x2a
  brne mainLoop0Check

  ldi rTmp2,4
  nop

  ; check for magic sequence of 3rd value and restart counter2
1:
  in rTmp,ADDR_PIN
  sbis OE_PIN,OE_P
    rjmp 1f
  dec rTmp2
  breq mainLoop2Exit
  nop
  rjmp 1b
1:
  cpi rTmp,0x15
  brne mainLoop0Check

  ldi rTmp2,4
  nop

  ; check for magic sequence of 4th value and restart counter2
1:
  in rTmp,ADDR_PIN
  sbis OE_PIN,OE_P
    rjmp 1f
  dec rTmp2
  breq mainLoop2Exit
  nop
  rjmp 1b
1:
  cpi rTmp,0x3f
  brne mainLoop0Check

  dotWait 2

  ; get command
  waitOe rCmd      ; 0+4
  dotWait 1        ; 4+1
  sbrc rCmd,0      ; 5+1
    rjmp mainLoopInSync ; 6+2/1



  bst rCmd,0       ; 7+1
  brts invalidCmd  ; 0+2/1

  ; get cmd-func-ptr from lookup and jump to it

  dotWait 1        ; 1+1
  add rCmd,rLookup ; 2+1
  ld zl,x+         ; 3+2
  ld zh,x          ; 5+1
  ijmp             ; 6+2


mainLoop0Check:
  ldi rTmp2,4
  cpi rTmp,0

  dotWait 3
  breq 1f

  dotWait 1
  rjmp mainLoopInSync
1:
  rjmp mainLoop2a
invalidCmd:
  dotWait 4 ; 2+4
  rjmp mainLoopInSync ; 6+2



