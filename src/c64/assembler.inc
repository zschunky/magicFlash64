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

.macro  ldax    arg
  .if (.match (.left (1, {arg}), #))
    ; immediate mode
    lda     #<(.right (.tcount ({arg})-1, {arg}))
    ldx     #>(.right (.tcount ({arg})-1, {arg}))
  .else
    ; assume absolute or zero page
    lda     arg
    ldx     1+(arg)
    .endif
.endmacro
.macro stax arg
  .if (.match (.left (1, {arg}), #))
    ; immediate mode
    sta     #<(.right (.tcount ({arg})-1, {arg}))
    stx     #>(.right (.tcount ({arg})-1, {arg}))
  .else
    ; assume absolute or zero page
    sta     arg
    stx     1+(arg)
    .endif
.endmacro

.macro inc16 addr
.scope
  inc addr
  bne next
    inc addr+1
next:
.endscope
.endmacro

.macro dec16 addr
.scope
  lda addr
  bne next
    dec addr+1
next:
  dec addr
.endscope
.endmacro

.macro dec16Branch addr, branchAddr
.scope
  lda addr
  bne next
    dec addr+1
next:
  dec addr
  bne branchAddr

  lda addr+1
  bne branchAddr
.endscope
.endmacro
.macro  push    r1, r2, r3, r4, r5, r6, r7,r8,r9,r10,r11,r12,r13,r14,r15
  .ifblank r1
    .exitmacro
  .else
    lda r1
    pha
  .endif
  push    r2, r3, r4, r5, r6, r7,r8,r9,r10,r11,r12,r13,r14,r15
.endmacro
.macro  pop    r1, r2, r3, r4, r5, r6, r7,r8,r9,r10,r11,r12,r13,r14,r15
  .ifblank r1
    .exitmacro
  .else
    pla
    sta r1
  .endif
  pop    r2, r3, r4, r5, r6, r7,r8,r9,r10,r11,r12,r13,r14,r15
.endmacro
