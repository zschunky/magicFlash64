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
.include "c64.inc"
.include "zeropage.inc"

;incBegin
.define BOOT_SLOT 63
;incEnd

.data

seq:
  STEP $00
  STEP $2A
  STEP $15
  STEP $3F
  rts
  
.export noBad
noBad:
  NO_BAD
  rts

.export mf64StepA
mf64StepA:
  STEPA
  rts

; void __fastcall__ mf64Led(uint8_t mode);
.export _mf64Led
_mf64Led:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_LED
  jsr mf64StepA
  plp
  rts
  

; void mf64Reset();
.export _mf64Reset
_mf64Reset:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_RESET
  plp
  rts

; void mf64Stall();
.export _mf64Stall
_mf64Stall:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_STALL
  plp
  rts

; void __fastcall__ mf64Select(uint8_t slot);
.export _mf64Select
_mf64Select:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_SELECT
  jsr mf64StepA
  plp
  rts

; void __fastcall__ mf64SelectAfterInt(uint8_t slot);
.export _mf64SelectAfterInt
_mf64SelectAfterInt:
  php
  sei
  pha
  txa
  jsr noBad
  jsr seq
  STEP CMD_SELECT_AFTER_INT
  jsr mf64StepA
  pla
  jsr mf64StepA
  plp
  rts

; void __fastcall__ mf64SelectAfterRestoreInt(uint8_t slot);
.export _mf64SelectAfterRestoreInt
_mf64SelectAfterRestoreInt:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_SELECT_AFTER_RESTORE_INT
  jsr mf64StepA
  plp
  rts


; void __fastcall__ mf64SetDefault(uint8_t slot);
.export _mf64SetDefault
_mf64SetDefault:
  ; disable irq
  php
  sei

  ; execute setDefault sequence
  jsr seq
  STEP CMD_SET_DEFAULT
  jsr mf64StepA

  ; restore interrupt bit
  plp
  rts

; uint8_t mf64GetDefault()
.export _mf64GetDefault
_mf64GetDefault:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getDefault sequence
  jsr seq
  STEP CMD_GET_DEFAULT

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; uint8_t mf64GetMode()
.export _mf64GetMode
_mf64GetMode:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getMode sequence
  jsr seq
  STEP CMD_GET_MODE

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; uint8_t mf64GetRecoveryVersion()
.export _mf64GetRecoveryVersion
_mf64GetRecoveryVersion:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getMode sequence
  jsr seq
  STEP CMD_GET_RECOVERY_VERSION

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts


; uint8_t mf64GetPrev()
.export _mf64GetPrev
_mf64GetPrev:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getPrev sequence
  jsr seq
  STEP CMD_GET_PREV

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; uint8_t mf64GetSelected()
.export _mf64GetSelected
_mf64GetSelected:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getSelected sequence
  jsr seq
  STEP CMD_GET_SELECTED

  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; void __fastcall__ mf64SetRam x:slot a:data
.export _mf64SetRam
_mf64SetRam:
  ; disable irq
  php
  sei

  ;remember data
  sta tmp3
  txa

  ; execute setRam sequence
  jsr noBad
  jsr seq
  STEP CMD_SET_RAM
mf64AddrNibbles:
  jsr mf64StepA

  ; get low nibble
  lda tmp3
  and #$0f
  jsr mf64StepA

  ; get high nibble
  lda tmp3
  lsr
  lsr
  lsr
  lsr
  jsr mf64StepA

  ; restore interrupt bit
  plp
  rts

; uint8_t mf64GetRam(uint8_t slot)
.export _mf64GetRam
_mf64GetRam:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getRam sequence
  jsr seq
  STEP CMD_GET_RAM
  jsr mf64StepA

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; void __fastcall__ mf64SetEeprom x:slot a:data
.export _mf64SetEeprom
_mf64SetEeprom:
  ; disable irq
  php
  sei

  ;remember data
  sta tmp3
  txa

  ; execute setEeprom sequence
  jsr noBad
  jsr seq
  STEP CMD_SET_EEPROM
  jmp mf64AddrNibbles

; uint8_t mf64GetEeprom(uint8_t slot)
.export _mf64GetEeprom
_mf64GetEeprom:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getEeprom sequence
  jsr seq
  STEP CMD_GET_EEPROM
  jsr mf64StepA

  ; read value
  jsr mf64Read

  ; restore interrupt bit
  plp
  rts

; uint16_t mf64GetVersion()
.export _mf64GetVersion
_mf64GetVersion:
  ; disable irq
  php
  sei

  ; execute getVersion sequence
  jsr noBad
  jsr seq
  STEP CMD_GET_VERSION


  jsr mf64Read
  pha
  jsr mf64Read
  tax
  pla

  ; restore interrupt bit
  plp
  rts



.export mf64Read
mf64Read:
  ; backup nmi vector
  ldy $0318
  ldx $0319
  sty tmp3
  stx tmp4

  ; set mf64ReadNmi as nmi vector
  ldy #<mf64ReadNmi
  ldx #>mf64ReadNmi
  sty $0318
  stx $0319

  ; loop over 8 bits
  ldx #8
  stx tmp2
  ldx #0
  stx tmp5
:
  ; reset x-register and done flag
  ldy #0
  sty tmp1

  jsr noBad

  ; trigger new bit
  ROMRD $0000

  ; give some time to allow nmi to trigger
  ldx #14
:
  iny
  bne :-
  dex
  bne :-

  ; set carry if nmi occored otherwise clear
  clc
  ldy tmp1
  beq :++

:
  iny
  bne :-

  sec
:

  ; shift carry into result
  ror tmp5

  ; trigger bit received in case some cart hold nmi down
  STEP $3f

  ; decrement bit count and jmp as long not all 8 bits have been processed
  dec tmp2
  bne :----

  ; restore nmi vector
  ldy tmp3
  ldx tmp4
  sty $0318
  stx $0319

  ; get result
  lda tmp5
  rts

.export mf64ReadNmi
mf64ReadNmi:
  inc tmp1
  rti
.export mf64End
mf64End:

  

