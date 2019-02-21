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

.data
lookup:
.word pm(cmdLed)
.word pm(cmdReset)
.word pm(cmdSelect)
.word pm(cmdWrModeAutoSelect)
.word pm(cmdWrModeProgram)
.word pm(cmdWrModeErase)
.word pm(cmdFwUpd)
.word pm(cmdSetDefault)
.word pm(cmdGetDefault)
.word pm(cmdGetSelected)
.word pm(cmdSetEeprom)
.word pm(cmdGetEeprom)
.word pm(cmdWrModeReset)
.word pm(cmdTest)
.word pm(cmdGetPrev)
.word pm(cmdSetRam)
.word pm(cmdGetRam)
.word pm(cmdGetVersion)
.word pm(cmdMcType)
.word pm(cmdSelectAfterInt)
.word pm(cmdSelectPrev)
.word pm(cmdSelectAfterRestoreInt)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)
.word pm(cmdNop)

lookupLedFull:
.word (LED_FULL_CNT / 8)*0
.word (LED_FULL_CNT / 8)*1
.word (LED_FULL_CNT / 8)*2
.word (LED_FULL_CNT / 8)*3
.word (LED_FULL_CNT / 8)*4
.word (LED_FULL_CNT / 8)*5
.word (LED_FULL_CNT / 8)*6
.word (LED_FULL_CNT / 8)*7

lookupLedHalf:
.word (LED_HALF_CNT / 8)*0
.word (LED_HALF_CNT / 8)*1
.word (LED_HALF_CNT / 8)*2
.word (LED_HALF_CNT / 8)*3
.word (LED_HALF_CNT / 8)*4
.word (LED_HALF_CNT / 8)*5
.word (LED_HALF_CNT / 8)*6
.word (LED_HALF_CNT / 8)*7



.section .bss
ram:
.skip 64
