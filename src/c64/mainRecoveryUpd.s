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
  jsr _ekLed

  jsr _ekGetSelected
  sta slot

  ; get mode
  jsr _ekGetMode

  ; make sure we are in normal mode
  cmp #2 
  beq :+++
    jsr restoreZp
    cli
    ldx #0
:
      lda invalidMsg,x
      beq :+
      jsr $ffd2
      inx
      bne :-
:
    rts
:

  ; check recovery version
  jsr _ekGetRecoveryVersion
  cmp #VER_RECOVERY
  bne :+++
    lda #$18
    jsr _ekLed

    jsr restoreZp
    cli
    ldx #0
:
      lda upToDateMsg,x
      beq :+
      jsr $ffd2
      inx
      bne :-
:
    rts
:

  jsr _ekGetMcType
  cmp #MC_TYPE_ATMEGA48_M20
  bne :+
    lda #<fwM20
    ldx #>fwM20
    jmp updCont
:
  cmp #MC_TYPE_ATMEGA48_DOT
  bne :+
    lda #<fwDot
    ldx #>fwDot
    jmp updCont
:
  lda #$18
  jsr _ekLed

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

updCont:
  jsr _ekRecoveryUpd

  ; give atmega some time to restart
  ldx #0
  ldy #32
:
    dex
    bne :-
    dey
    bne :-

  lda slot
  jsr _ekSelect

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
.export invalidMsg
invalidMsg:
  .byte "invalid mode or not supported",13,0
.export upToDateMsg
upToDateMsg:
  .byte "version already installed - abort",13,0
.export wrongMcType
wrongMcType:
  .byte "unknown microcontroller detected - abort",13,0
fwM20:
  .incbin "mf64-m20-firmware.bin",RECOVERY_ADDR,FW_ADDR-RECOVERY_ADDR
fwDot:
  .incbin "mf64-dot-firmware.bin",RECOVERY_ADDR,FW_ADDR-RECOVERY_ADDR
  


  
