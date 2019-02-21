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



.macro _screenLineStr ch, count, str, nextPos
  .if nextPos < .strlen(str)
    .if ch = .strat(str, nextPos)
	  _screenLineStr ch, count+1, str, nextPos+1
	  .exitmacro
	.endif
  .endif

  .if count = 1
    scrcode ch
  .elseif count = 2
    scrcode ch, ch
  .else
    .byte $80+count
	scrcode ch
  .endif  
  
  .if nextPos < .strlen(str)
    _screenLineStr .strat(str, nextPos), 1, str, nextPos+1
  .endif
.endmacro

.macro _screenLine num, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
  .if     .blank ({arg1})
    .if (num < 40)
	  .byte $f0 + 40 - num, $ff
	.endif
    .exitmacro
  .endif   
   
  .if .match ({arg1}, "")
    _screenLineStr .strat(arg1,0), 1, arg1, 1
	_screenLine num+.strlen(arg1), arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
  .else
    .byte arg1
    .if arg1 < $f0
	  _screenLine num, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
	.elseif arg = $80
	  .exitmacro
	.elseif arg > $80
	  .byte arg2
	  _screenLine num+arg1-$80, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
	.else
	  _screenLine num+1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
	.endif
  .endif
.endmacro

.macro screenLine arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
  _screenLine 0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
.endmacro

