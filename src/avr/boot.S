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

.global __vectors
.global cmdFwUpdImpl
.global setSelectImpl

.section .boot,"ax",@progbits
  rjmp boot
  rjmp __vectors+2
  rjmp __vectors+4
  rjmp __vectors+6
  rjmp __vectors+8
  rjmp __vectors+10
  rjmp __vectors+12
  rjmp __vectors+14
  rjmp __vectors+16
  rjmp __vectors+18
  rjmp __vectors+20
  rjmp __vectors+22
  rjmp __vectors+24
  rjmp __vectors+26
  rjmp __vectors+28
  rjmp __vectors+30
  rjmp __vectors+32
  rjmp __vectors+34
  rjmp __vectors+36
  rjmp __vectors+38
  rjmp __vectors+40
  rjmp __vectors+42
  rjmp __vectors+44
  rjmp __vectors+46
  rjmp __vectors+48
  rjmp __vectors+50

boot:
  ; check for recovery mode
  sbic SCL_PIN,SCL_P
  rjmp __vectors

  rjmp recovery

