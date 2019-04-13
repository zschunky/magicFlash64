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

.include "magicFlash64.inc"
.include "magicFlash64Lib.inc"
.include "zeropage.inc"
.include "breakPoint.inc"

;incBegin
.define MC_TYPE_ATMEGA48_M20 4
.define MC_TYPE_ATMEGA48_DOT 104
;incEnd

.data

.export _mf64Error
_mf64Error:
  .res 1

; uint8_t __fastcall__ mf64WrAutoSelect(uint8_t addr);
.export _mf64WrAutoSelect
_mf64WrAutoSelect:
  php
  sei
  sta :+ + 1 
  jsr noBad
  SEQ CMD_WR_MODE_AUTO_SELECT
  ldx #$aa
  ROMWRX $5555
  ldx #$55
  ROMWRX $2aaa
  ldx #$90
  ROMWRX $5555
  
:
  ROMRDA $0000
  ldx #$f0
  ROMWRX $0000

  plp
  rts

; void __fastcall__ mf64WrProgram(uint8_t *data);
.export _mf64WrProgram
_mf64WrProgram:
;  jsr breakPoint
;  lda #0
;  sta _mf64Error
;  rts

  php
  sei
  sta tmp1 
  stx tmp2

  lda #$00
  sta _mf64Error
  sta tmp3
  lda #$e0
  sta tmp4

  ldy #0
mf64WrProgramLoop:
  lda #16
  sta tmp6
mf64WrProgramRetry:
  jsr noBad

  lda (tmp1),y
  cmp (tmp3),y
  beq mf64WrProgramCont

  SEQ CMD_WR_MODE_PROGRAM
  ldx #$aa
  ROMWRX $5555
  ldx #$55
  ROMWRX $2aaa
  ldx #$a0
  ROMWRX $5555
  ldx #0
  sta (tmp3,x)
  

  lda #$20

  bit $e000
  bvc toggleCleared

toggleSet:
  jsr noBad
  bit $e000
  bvs mf64WrProgramRetry2
;  bvs mf64WrProgramCont
  bne stage2

toggleCleared:
  jsr noBad
  bit $e000
  bvc mf64WrProgramRetry2
  ;bvc mf64WrProgramCont
  bne stage2
  beq toggleSet

stage2:
  bit $e000
  bvc stage2Cleared

stage2Set:
  bit $e000
  bvs mf64WrProgramRetry2
  ;bvs mf64WrProgramCont

error:
  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000

mf64WrProgramRetry2:
  dec tmp6
  bne mf64WrProgramRetry
  ; fail
  lda #1
  sta _mf64Error
  jmp mf64WrProgramCont
stage2Cleared:
  bit $e000
  bvs error
  bvc mf64WrProgramRetry2 ;****

mf64WrProgramCont:
;  lda tmp3
;  sta $0400
;  lda tmp4
;  sta $0401

  inc tmp1
  bne :+
  inc tmp2
:
  inc tmp3
  ;bne mf64WrProgramLoop
  beq :+
    jmp mf64WrProgramLoop
:
  inc tmp4
  ;bne mf64WrProgramLoop
  beq :+
    jmp mf64WrProgramLoop
:

  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000
  plp
  rts

; void mf64WrErase();
.export _mf64WrErase
_mf64WrErase:
;  lda #0
;  sta _mf64Error
;  rts

  php
  sei

  lda #0
  sta _mf64Error

  jsr noBad

  SEQ CMD_WR_MODE_ERASE
  ldx #$aa
  ROMWRX $5555
  ldx #$55
  ROMWRX $2aaa
  ldx #$80
  ROMWRX $5555
  ldx #$aa
  ROMWRX $5555
  ldx #$55
  ROMWRX $2aaa
  ldx #$30
  ROMWRX $0000

mf64WrEraseRd:
  jsr noBad
  ROMRDA $0000
  tax
  and #$80
  cmp #$80
  beq mf64WrEraseDone

  txa
  and #$20
  beq mf64WrEraseRd

  ROMRDA $0000
  and #$80
  cmp #$80
  beq mf64WrEraseDone

  ; fail
  inc _mf64Error

  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000

  plp
  rts


mf64WrEraseDone:

  plp
  rts

.export _mf64RecoveryUpd
_mf64RecoveryUpd:
  php
  sei

  sta tmp3
  stx tmp4

  lda #$40
  sta tmp5

  lda #<((FW_ADDR-RECOVERY_ADDR)/(2*$20))
  sta tmp6

  jsr noBad
  SEQ CMD_RECOVERY_UPD

  jmp mf64FwUpdLoop

; void __fastcall__ mf64FwUpdOld(uint8_t *data, uint16_t len);
.export _mf64FwUpdOld
_mf64FwUpdOld:
  php
  sei

  sta tmp3
  stx tmp4

  lda #$40
  sta tmp5

  lda #<($1000/2/$20)
  sta tmp6

  
  jsr noBad
  SEQ CMD_FW_UPD_OLD

  jmp mf64FwUpdLoop

; void __fastcall__ mf64FwUpd(uint8_t *data, uint16_t len);
.export _mf64FwUpd
_mf64FwUpd:
  php
  sei

  sta tmp3
  stx tmp4

  lda #$40
  sta tmp5

  lda #<(($1000-FW_ADDR)/2/$20)
  sta tmp6

  
  jsr noBad
  SEQ CMD_FW_UPD

mf64FwUpdLoop:
  jsr noBad

  ldy #0
  lda (tmp3),y
  and #$0f
  STEPA

  ldy #0
  lda (tmp3),y
  lsr a
  lsr a
  lsr a
  lsr a
  STEPA

  inc tmp3
  bne :+
  inc tmp4
:
  dec tmp5
  bne mf64FwUpdLoop

  lda #$40
  sta tmp5

  ldx #0
  ldy #8
:
  dex
  bne :-
  dey
  bne :-

  dec tmp6
  bne mf64FwUpdLoop
fwUpdDone:
  jsr noBad
  STEP $3f

  plp
  rts

; uint16_t mf64GetMcType()
.export _mf64GetMcType
_mf64GetMcType:
  ; disable irq
  php
  sei

  ; execute getMcType sequence
  jsr noBad
  SEQ CMD_GET_MC_TYPE


  jsr mf64Read

  ; restore interrupt bit
  plp
  rts



