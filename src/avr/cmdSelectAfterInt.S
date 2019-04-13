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
cmdSelectAfterInt:
  ; get ignoreCount argument
  waitOe
  inc rTmp
  mov rTmp10,rTmp
  dotWait 2

  ; get slot argument
  waitOe
  mov rTmp9,rTmp

  ; reset rLed
  ldi rLed,0
  rcall setLed
  
  mov rTmp,rTmp9
  rcall waitInt

  ; reset rLed
  ldi rLed,8
  rcall setLed

  ; done, back to mainLoop
  rjmp mainBegin

