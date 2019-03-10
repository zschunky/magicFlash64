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

.data

.export _ekError
_ekError:
  .res 1

; uint8_t __fastcall__ ekWrAutoSelect(uint8_t addr);
.export _ekWrAutoSelect
_ekWrAutoSelect:
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

; void __fastcall__ ekWrProgram(uint8_t *data);
.export _ekWrProgram
_ekWrProgram:
;  jsr breakPoint
;  lda #0
;  sta _ekError
;  rts

  php
  sei
  sta tmp1 
  stx tmp2

  lda #$00
  sta _ekError
  sta tmp3
  lda #$e0
  sta tmp4

  ldy #0
ekWrProgramLoop:
  lda #16
  sta tmp6
ekWrProgramRetry:
  jsr noBad

  lda (tmp1),y
  cmp (tmp3),y
  beq ekWrProgramCont

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
  bvs ekWrProgramRetry2
;  bvs ekWrProgramCont
  bne stage2

toggleCleared:
  jsr noBad
  bit $e000
  bvc ekWrProgramRetry2
  ;bvc ekWrProgramCont
  bne stage2
  beq toggleSet

stage2:
  bit $e000
  bvc stage2Cleared

stage2Set:
  bit $e000
  bvs ekWrProgramRetry2
  ;bvs ekWrProgramCont

error:
  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000

ekWrProgramRetry2:
  dec tmp6
  bne ekWrProgramRetry
  ; fail
  lda #1
  sta _ekError
  jmp ekWrProgramCont
stage2Cleared:
  bit $e000
  bvs error
  bvc ekWrProgramRetry2 ;****

ekWrProgramCont:
;  lda tmp3
;  sta $0400
;  lda tmp4
;  sta $0401

  inc tmp1
  bne :+
  inc tmp2
:
  inc tmp3
  ;bne ekWrProgramLoop
  beq :+
    jmp ekWrProgramLoop
:
  inc tmp4
  ;bne ekWrProgramLoop
  beq :+
    jmp ekWrProgramLoop
:

  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000
  plp
  rts

; void ekWrErase();
.export _ekWrErase
_ekWrErase:
;  lda #0
;  sta _ekError
;  rts

  php
  sei

  lda #0
  sta _ekError

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

ekWrEraseRd:
  jsr noBad
  ROMRDA $0000
  tax
  and #$80
  cmp #$80
  beq ekWrEraseDone

  txa
  and #$20
  beq ekWrEraseRd

  ROMRDA $0000
  and #$80
  cmp #$80
  beq ekWrEraseDone

  ; fail
  inc _ekError

  jsr noBad
  SEQ CMD_WR_MODE_RESET
  ldx #$f0
  ROMWRX $0000

  plp
  rts


ekWrEraseDone:

  plp
  rts

.export _ekRecoveryUpd
_ekRecoveryUpd:
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

  jmp ekFwUpdLoop

; void __fastcall__ ekFwUpd(uint8_t *data, uint16_t len);
.export _ekFwUpd
_ekFwUpd:
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

ekFwUpdLoop:
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
  bne ekFwUpdLoop

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
  bne ekFwUpdLoop
fwUpdDone:
  jsr noBad
  STEP $3f

  plp
  rts

; uint16_t ekGetMcType()
.export _ekGetMcType
_ekGetMcType:
  ; disable irq
  php
  sei

  ; execute getMcType sequence
  jsr noBad
  SEQ CMD_GET_MC_TYPE


  jsr ekRead

  ; restore interrupt bit
  plp
  rts



