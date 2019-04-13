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
.include "magicFlash64Colors.inc"
.include "magicFlash64Lib.inc"
.include "zeropage.inc"
.include "screenCpy.inc"
.include "frame.inc"
.include "num.inc"
.include "screenNum.inc"
.macpack cbm

.zeropage
.exportzp enMask
enMask:
  .res 1
cnt:
  .res 1
.macro STEP value
  ROMRD ((value & $3e) << 7)|(value & 1)
.endmacro
.macro SETA
  ldx #0
  lsr
  bcc :+
  inx
:
  stx tmp1
  ora #$e0
  sta tmp2
  ldy #0
.endmacro
.macro STEPA
  SETA
  lda (tmp1),y
.endmacro
.macro SEQ cmd
  STEP $00
  STEP $2A
  STEP $15
  STEP $3F
  STEP cmd
.endmacro
.define CMD_TEST 26

.macro ROMRD addr
  bit $e000|((addr)&$1fff)
.endmacro

.segment "LOADADDR"
.export __LOADADDR__
__LOADADDR__:
.lobytes $0801
.hibytes $0801

.segment "EXEHDR"
.byte $0B, $08, $F0, $02, $9E, $32, $30, $36, $31, $00, $00, $00

.macro noBadImpl
:
  lda VIC_HLINE
  sec
  sbc #1
  and #7
  cmp #3
  bcc :-
.endmacro

.segment "STARTUP"
.export __STARTUP__
__STARTUP__:
  sei

  ; set lowercase char
  lda #$17
  sta VIC_VIDEO_ADR

  ; set background color
  lda #COLOR_BACKGROUND
  sta VIC_BORDERCOLOR
  sta VIC_BG_COLOR0

  ; disable interrupts/nmi from vic/cia
  lda #$9f
  sta CIA2_ICR
  sta CIA1_ICR
  lda #00
  sta VIC_IMR

  lda #<testFrameVer
  sta screenPtr
  lda #>testFrameVer
  sta screenPtr+1

  lda #VER_TEST_MAJOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ldy #0
  lda #46
  sta (screenPtr),y
  inc screenPtr
  bne :+
    inc screenPtr+1
:

  lda #VER_TEST_MINOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0
    
  ; clear screen
  jsr _screenClear

  lda #<testFrame
  ldx #>testFrame
  jsr _screenCpy

  lda #<testText
  ldx #>testText
  jsr _screenCpy

  lda #0
  sta cnt

  ; execute test sequence
  noBadImpl
  SEQ CMD_TEST
  lda #7
  sta enMask
  STEPA
loop:
  lda cnt
  sta $0400

  ; set rd/write regs
  lda cnt
  and #$3f
  SETA
  lda tmp1
  eor #$01
  sta tmp3
  lda tmp2
  eor #$1f
  sta tmp4

  ; trigger start
  noBadImpl
  STEP 0

  lda enMask
  and #1
  beq wrCheck

  ; read check
  ldy #0
  ldx #16
loopRd:
  noBadImpl
  lda (tmp1),y
  noBadImpl
  lda (tmp3),y
  dex
  bne loopRd

wrCheck:
  lda enMask
  and #2
  beq rdBckCheck

  ldx #0
  ldy #16
loopWr:
  noBadImpl
  sta (tmp1,x)
  noBadImpl
  sta (tmp3,x)
  dey
  bne loopWr

rdBckCheck:
  lda enMask
  and #4
  beq cont

  ; read back
  jsr ekRead

  sta $0401
  cmp cnt
  bne error


cont:
  inc cnt
  jmp loop
  


.export error
error:
  inc $d020
  jmp error

.export testFrame
testFrame:
  frameTitle "magicFlash64-test v       ", 32, 15
testFrameVer=testFrame + frameTitleOffset "magicFlash64-test v"


.export testText
testText:
  frameAddrTitle 32,15
  screenLine SC(WHITE),"the test is now running, in   "
  screenLine           "case the test fails the border"
  screenLine           "will change. The power LED    "
  screenLine           "will indicate the type of     "
  screenLine           "fail:                         "
  screenLine           "   LED off->readback fail     "
  screenLine           "   LED on->read fail          "
  screenLine           "   LED blinking->write fail   "
  screenLine           "                              "
  screenLine           "to stop the test power off the"
  screenLine           "C64 (reset is not enough)     ",C_END




