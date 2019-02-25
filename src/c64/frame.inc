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



.macro frameAddrAbs w,h
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)
.endmacro
.macro frameAddrAbsLo w,h,offset
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2) + offset
.endmacro
.macro frameAddrAbsHi w,h,offset
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2) + offset
.endmacro


.macro frameAddr w,h
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+41
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+41
.endmacro
.macro frameAddrLo w,h,offset
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+41 + offset
.endmacro
.macro frameAddrHi w,h,offset
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+41 + offset
.endmacro

.macro frameAddrTitle w,h
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+121
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+121
.endmacro
.macro frameAddrTitleLo w,h,offset
  .lobytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+121 + offset
.endmacro
.macro frameAddrTitleHi w,h,offset
  .hibytes $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)+121 + offset
.endmacro

.define frameTitleOffset(t) .strlen(t)+11
.define frameTitleBodyOffset(w,h) $0400 + ((25-(h))/2) * 40 + ((40-(w))/2)
.macro frameTitle t,w,h
  frameAddrAbs w,h
  .byte $f0 + COLOR_BORDER,112,$80+(w-2),64,110
  .if w < 40
    .byte $80+40-(w),$ff
  .endif
  .byte 93,$f0 + COLOR_TITLE
  scrcode t
  .if (w)-.strlen(t)-2 > 0
    .if (((w)-.strlen(t))-2)>2
      .byte $80+(((w)-.strlen(t))-2),$20
    .else
      .repeat(((w)-.strlen(t))
        .byte $20
      .endrepeat
    .endif
  .endif
  .byte $f0 + COLOR_BORDER, 93
  .if w < 40
    .byte $80+40-(w),$ff
  .endif
  .byte 107,$80+((w)-2),64,115
  .if w < 40
    .byte $80+40-(w),$ff
  .endif
.repeat h-4
  .byte 93,$f0+COLOR_FRAME,$80+((w)-2),$20,$f0+COLOR_BORDER,93
  .if w < 40
    .byte $80+40-(w),$ff
  .endif
.endrepeat
  .byte 109,$80+((w)-2),64,125,$80
.endmacro

.macro frame w,h
  frameAddrAbs w,h
  .byte $f0+COLOR_BORDER,112,$80+((w)-2),64,110,$80+40-(w),$ff
.repeat h-2
  .byte 93,$f0+COLOR_FRAME,$80+((w)-2),$20,$f0+COLOR_BORDER,93,$80+40-(w),$ff
.endrepeat
  .byte 109,$80+((w)-2),64,125,$80
.endmacro

   
