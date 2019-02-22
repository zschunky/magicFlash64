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


.include "c64.inc"
.include "zeropage.inc"

;incBegin
.define SC(color) $f0+color
.define SR(repeatCount) $80+repeatCount
.define C_H  64 
.define C_V  93
.define C_UR 109
.define C_UL 125
.define C_DR 112
.define C_DL 110
.define C_VH 91
.define C_HU 113
.define C_HD 114
.define C_VL 115
.define C_VR 107
.define C_SP 32
.define C_END $80

.macro _screenLineStr pos, count, str
  .if pos + 1 < .strlen(str)
    .if .strat(str, pos)= .strat(str, pos + 1)
      _screenLineStr pos+1, count+1, str
      .exitmacro
    .endif
  .endif

  .if count = 1
    _scrcode {.strat(str, pos)}
  .elseif count = 2
    _scrcode {.strat(str, pos)}
    _scrcode {.strat(str, pos)}
  .else
    .byte $80+count
    _scrcode {.strat(str, pos)}
  .endif  
  
  .if pos + 1 < .strlen(str)
    _screenLineStr pos+1, 1, str
  .endif
.endmacro

.macro _screenLine num, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
  .if .blank ({arg1})
    .if (num < 40)
      .byte $80 + 40 - (num), $ff
    .endif
    .exitmacro
  .endif   
   
  .if .match ({arg1}, "")
    _screenLineStr 0, 1, arg1
    _screenLine num+.strlen(arg1), arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
  .elseif .match(.right(1,{arg1}),:)
    ;.export .ident(.left(.strlen(.string(arg1))-1,{arg1}))
    arg1
  .else
    .byte arg1
    .if arg1 >= $f0
      _screenLine num, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
    .elseif arg1 = $80
      .exitmacro
    .elseif arg1 > $80
      .byte arg2
      _screenLine num+arg1-$80, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
    .else
      _screenLine num+1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
    .endif
  .endif
.endmacro

.macro screenLine arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
  _screenLine 0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30
.endmacro
;incEnd

.define srcPtr tmp1
.define screenPtr tmp3
.define colorPtr tmp5
.define color tmp7
.define repeatChar tmp8

.code
.export _screenCpy
_screenCpy:
  sta srcPtr
  stx srcPtr+1
  ldy #$00
  lda (srcPtr),y
  sta screenPtr
  sta colorPtr

  inc srcPtr
  bne :+
  inc srcPtr+1
:
  lda (srcPtr),y
  sta screenPtr+1
  clc
  adc #$d4
  sta colorPtr+1

  inc srcPtr
  bne :+
  inc srcPtr+1
:
  lda #1
  sta color

loop:
  lda (srcPtr),y

  inc srcPtr
  bne :+
  inc srcPtr+1
:
  cmp #$80
  bcs specialChar

  sta (screenPtr),y
  lda color
  sta (colorPtr),y

  inc screenPtr
  inc colorPtr
  bne loop
  inc screenPtr+1
  inc colorPtr+1
  jmp loop

specialChar:
  cmp #$f0
  bcs setColor

  and #$7f
  bne repeat
  rts

repeat:
  tax

  lda (srcPtr),y
  
  inc srcPtr
  bne :+
  inc srcPtr+1
:
  cmp #$ff
  beq skip

  sta repeatChar

loopRepeat:
  dex
  bmi loop

  lda repeatChar
  sta (screenPtr),y
  lda color
  sta (colorPtr),y

  inc screenPtr
  inc colorPtr
  bne loopRepeat
  inc screenPtr+1
  inc colorPtr+1
  jmp loopRepeat
skip:
  txa
  clc
  adc screenPtr
  sta screenPtr
  sta colorPtr
  bcc :+
  inc screenPtr+1
  inc colorPtr+1
:
  jmp loop

setColor:
  sta color
  jmp loop

  
.export _screenClear
_screenClear:
  tay
  ldx #0
:
  lda #32
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  tya
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne :-
  rts
  
