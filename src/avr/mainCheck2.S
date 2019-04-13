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

.section .recovery,"ax",@progbits
recovery:
  rjmp __vectors

.text
.global main
main:
  ldi rTmp,0x55
  ldi rTmp2,0xaa
  out DDRC,rTmp
  out PORTC,rTmp2

  out DDRD,rTmp2
  out PORTD,rTmp

  out DDRB,rTmp2
  out PORTB,rTmp
1:
  rjmp 1b
