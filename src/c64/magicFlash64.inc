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


.define CMD_LED 0
.define CMD_RESET 2
.define CMD_SELECT 4
.define CMD_WR_MODE_AUTO_SELECT 6
.define CMD_WR_MODE_PROGRAM 8
.define CMD_WR_MODE_ERASE 10
.define CMD_FW_UPD_OLD 12
.define CMD_SET_DEFAULT 14
.define CMD_GET_DEFAULT 16
.define CMD_GET_SELECTED 18
.define CMD_SET_EEPROM 20
.define CMD_GET_EEPROM 22
.define CMD_WR_MODE_RESET 24
.define CMD_TEST 26
.define CMD_GET_PREV 28
.define CMD_SET_RAM 30
.define CMD_GET_RAM 32
.define CMD_GET_VERSION 34
.define CMD_GET_MC_TYPE 36
.define CMD_SELECT_AFTER_INT 38
.define CMD_SELECT_PREV 40
.define CMD_SELECT_AFTER_RESTORE_INT 42
.define CMD_GET_MODE 44
.define CMD_GET_RECOVERY_VERSION 46
.define CMD_RECOVERY_UPD 48
.define CMD_STALL 50
.define CMD_FW_UPD 52


.macro ROMRD addr
  bit $e000|((addr)&$1fff)
.endmacro
.macro ROMRDA addr
  lda $e000|((addr)&$1fff)
.endmacro
.macro ROMWRX addr
  stx $e000|((addr)&$1fff)
.endmacro
.macro ROMWRA addr
  sta $e000|((addr)&$1fff)
.endmacro
.macro STEP value
  ROMRD ((value & $3e) << 7)|(value & 1)
.endmacro

.macro STEPA
  ldx #0
  lsr
  bcc :+
  inx
:
  stx tmp1
  ora #$e0
  sta tmp2
  ldy #0
  lda (tmp1),y
.endmacro


.macro SEQ cmd
  STEP $00
  STEP $2A
  STEP $15
  STEP $3F
  STEP cmd
.endmacro

.macro NO_BAD
.scope
  pha
noBadLoop:
  lda VIC_HLINE
  sec
  sbc #1
  and #7
  cmp #3
  bcc noBadLoop

  pla
.endscope
.endmacro
