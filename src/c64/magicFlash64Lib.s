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

.export ekStepA
ekStepA:
  STEPA
  rts

; void __fastcall__ ekLed(uint8_t mode);
.export _ekLed
_ekLed:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_LED
  jsr ekStepA
  plp
  rts
  

; void ekReset();
.export _ekReset
_ekReset:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_RESET
  plp
  rts

; void __fastcall__ ekSelect(uint8_t slot);
.export _ekSelect
_ekSelect:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_SELECT
  jsr ekStepA
  plp
  rts

; void __fastcall__ ekSelectAfterInt(uint8_t slot);
.export _ekSelectAfterInt
_ekSelectAfterInt:
  php
  sei
  pha
  txa
  jsr noBad
  jsr seq
  STEP CMD_SELECT_AFTER_INT
  jsr ekStepA
  pla
  jsr ekStepA
  plp
  rts

; void __fastcall__ ekSelectAfterRestoreInt(uint8_t slot);
.export _ekSelectAfterRestoreInt
_ekSelectAfterRestoreInt:
  php
  sei
  jsr noBad
  jsr seq
  STEP CMD_SELECT_AFTER_RESTORE_INT
  jsr ekStepA
  plp
  rts


; void __fastcall__ ekSetDefault(uint8_t slot);
.export _ekSetDefault
_ekSetDefault:
  ; disable irq
  php
  sei

  ; execute setDefault sequence
  jsr seq
  STEP CMD_SET_DEFAULT
  jsr ekStepA

  ; restore interrupt bit
  plp
  rts

; uint8_t ekGetDefault()
.export _ekGetDefault
_ekGetDefault:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getDefault sequence
  jsr seq
  STEP CMD_GET_DEFAULT

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; uint8_t ekGetMode()
.export _ekGetMode
_ekGetMode:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getMode sequence
  jsr seq
  STEP CMD_GET_MODE

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; uint8_t ekGetRecoveryVersion()
.export _ekGetRecoveryVersion
_ekGetRecoveryVersion:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getMode sequence
  jsr seq
  STEP CMD_GET_RECOVERY_VERSION

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts


; uint8_t ekGetPrev()
.export _ekGetPrev
_ekGetPrev:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getPrev sequence
  jsr seq
  STEP CMD_GET_PREV

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; uint8_t ekGetSelected()
.export _ekGetSelected
_ekGetSelected:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getSelected sequence
  jsr seq
  STEP CMD_GET_SELECTED

  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; void __fastcall__ ekSetRam x:slot a:data
.export _ekSetRam
_ekSetRam:
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
ekAddrNibbles:
  jsr ekStepA

  ; get low nibble
  lda tmp3
  and #$0f
  jsr ekStepA

  ; get high nibble
  lda tmp3
  lsr
  lsr
  lsr
  lsr
  jsr ekStepA

  ; restore interrupt bit
  plp
  rts

; uint8_t ekGetRam(uint8_t slot)
.export _ekGetRam
_ekGetRam:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getRam sequence
  jsr seq
  STEP CMD_GET_RAM
  jsr ekStepA

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; void __fastcall__ ekSetEeprom x:slot a:data
.export _ekSetEeprom
_ekSetEeprom:
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
  jmp ekAddrNibbles

; uint8_t ekGetEeprom(uint8_t slot)
.export _ekGetEeprom
_ekGetEeprom:
  ; disable irq
  php
  sei

  jsr noBad

  ; execute getEeprom sequence
  jsr seq
  STEP CMD_GET_EEPROM
  jsr ekStepA

  ; read value
  jsr ekRead

  ; restore interrupt bit
  plp
  rts

; uint16_t ekGetVersion()
.export _ekGetVersion
_ekGetVersion:
  ; disable irq
  php
  sei

  ; execute getVersion sequence
  jsr noBad
  jsr seq
  STEP CMD_GET_VERSION


  jsr ekRead
  pha
  jsr ekRead
  tax
  pla

  ; restore interrupt bit
  plp
  rts



.export ekRead
ekRead:
  ; backup nmi vector
  ldy $0318
  ldx $0319
  sty tmp3
  stx tmp4

  ; set ekReadNmi as nmi vector
  ldy #<ekReadNmi
  ldx #>ekReadNmi
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

.export ekReadNmi
ekReadNmi:
  inc tmp1
  rti
.export ekEnd
ekEnd:

  

