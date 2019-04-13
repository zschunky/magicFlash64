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

.include "magicFlash64Lib.inc"
.include "magicFlash64LibPgm.inc"
.include "zeropage.inc"

.import __ZEROPAGE_SIZE__
.import __ZEROPAGE_RUN__
.segment "LOADADDR"
.export __LOADADDR__
__LOADADDR__:
.lobytes $0801
.hibytes $0801

.segment "EXEHDR"
.byte $0B, $08, $F0, $02, $9E, $32, $30, $36, $31, $00, $00, $00

.bss
fwPtr:
  .res 2

.segment "STARTUP"
.export __STARTUP__
__STARTUP__:
  sei

  ldx #0
:
    lda __ZEROPAGE_RUN__,x
    sta zpSave,x
    inx
    cpx #<__ZEROPAGE_SIZE__
    bne :-


  lda #$14
  jsr _mf64Led

  jsr _mf64GetSelected
  sta slot

  jsr _mf64GetMcType
  cmp #MC_TYPE_ATMEGA48_DOT
  bne :+
    lda #<fwDot
    sta fwPtr
    lda #>fwDot
    sta fwPtr+1
    jmp updCheckVersion
:
  cmp #MC_TYPE_ATMEGA48_M20
  beq :+
  cmp #0
  bne :++
:
    lda #<fwM20
    sta fwPtr
    lda #>fwM20
    sta fwPtr+1
    jmp updCheckVersion
:
  cli

  ldx #0
:
    lda wrongMcType,x
    beq :+
    jsr $ffd2
    inx
    bne :-
:

    rts

updCheckVersion:

  jsr _mf64GetVersion
  
  ; if mj >= 1 ; bootLoader and recovery are present
  cmp #0
  beq :+
    lda fwPtr
    clc
    adc #<FW_ADDR
    sta fwPtr
    lda fwPtr+1
    adc #>FW_ADDR
    sta fwPtr+1
    jmp updCont
:
  ; else if minor >= 1 ; old 0.x fw
  cpx #0
  bne updCont
  ; else 
  jsr _mf64GetMode
  ;   if mode == 1 ; recovery mode active
  cmp #1 
  bne :+
    lda #55
    sta slot

    lda fwPtr
    clc
    adc #<FW_ADDR
    sta fwPtr
    lda fwPtr+1
    adc #>FW_ADDR
    sta fwPtr+1
    jmp updCont
:
  ;   else if mode == 0 ; everything responded with 0 -> no magicFlash64 found
  cmp #0 
  bne :+++
    jsr restoreZp
    cli
    ldx #0
:
      lda nothingFoundMsg,x
      beq :+
      jsr $ffd2
      inx
      bne :-
:
    rts

:
  ;   else ; mode > 1 with ver=0.0 -> illegal
    jsr restoreZp
    cli
    ldx #0
:
      lda invalidModeMsg,x
      beq :+
      jsr $ffd2
      inx
      bne :-
:
    rts

updCont:
  lda fwPtr
  ldx fwPtr+1
  jsr _mf64FwUpd

  ; give atmega some time to restart
  ldx #0
  ldy #32
:
    dex
    bne :-
    dey
    bne :-



  lda slot
  jsr _mf64Select

  jsr restoreZp


  cli

  ldx #0
:
    lda doneMsg,x
    beq :+
    jsr $ffd2
    inx
    bne :-
:

  rts
restoreZp:
  ldx #0
:
    lda zpSave,x
    sta __ZEROPAGE_RUN__,x
    inx
    cpx #<__ZEROPAGE_SIZE__
    bne :-
  rts
.bss
zpSave:
 .res   $80

.code
.export doneMsg
doneMsg:
  .byte "update done",13,0
.export nothingFoundMsg
nothingFoundMsg:
  .byte "no magicflash64 detected",13,0
.export invalidModeMsg
invalidModeMsg:
  .byte "invalid mode detected",13,0
.export wrongMcType
wrongMcType:
  .byte "unknown microcontroller detected - abort",13,0
.export fwM20
fwM20:
  .incbin "mf64-m20-firmware.bin"
fwM20End:
  .res $1000-(fwM20End-fwM20),$ff
.export fwDot
fwDot:
  .incbin "mf64-dot-firmware.bin"
fwDotEnd:
  .res $1000-(fwDotEnd-fwDot),$ff
  


  
