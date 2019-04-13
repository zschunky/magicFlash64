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
  ; check for magic sequence of 1st value and restart counter2
  waitOe

  sts TCNT2,r00
mainLoop0:
  cpi rTmp,0
  brne mainLoop

  ; reset counter2 flags
  out TIFR2,rFF

  ; check for magic sequence of 2nd value and restart counter2
  waitOe
  sts TCNT2,r00
  cpi rTmp,0x2a
  brne mainLoop0

  ; reset counter2 flags and check if received magic value in time
  in rTmp,TIFR2
  out TIFR2,rFF
  cpi rTmp,1<<OCF2A
  brne mainLoop

  ; check for magic sequence of 3rd value and restart counter2
  waitOe
  sts TCNT2,r00
  cpi rTmp,0x15
  brne mainLoop0

  ; reset counter2 flags and check if received magic value in time
  in rTmp,TIFR2
  out TIFR2,rFF
  cpi rTmp,1<<OCF2A
  brne mainLoop

  ; check for magic sequence of 4th value and restart counter2
  waitOe
  sts TCNT2,r00
  cpi rTmp,0x3f
  brne mainLoop0

  ; reset counter2 flags and check if received magic value in time
  in rTmp,TIFR2
  out TIFR2,rFF
  cpi rTmp,1<<OCF2A
  brne mainLoop

  ; get command
  waitOe rCmd

  bst rCmd,0
  brts mainLoop
  ; get cmd-func-ptr from lookup and jump to it
  add rCmd,rLookup
  ld zl,x+
  ld zh,x
  ijmp

cmdNop:
  rjmp mainLoop




