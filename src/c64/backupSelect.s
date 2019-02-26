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
.include "screenCpy.inc"
.include "zeropage.inc"
.include "textProgrammerEn.inc"
.include "select.inc"
.include "selectSlot.inc"
.include "backupDisk.inc"
.include "backupReu.inc"
.include "backupGeoRam.inc"

.include "slot.inc"

.data
selectedBackupSelect:
  .byte 0

.bss
.export freeMemSlotPtr
freeMemSlotPtr:
  .res 2
.export newMemSlotPtr
newMemSlotPtr:
  .res 2
.export popMemSlotPtr
popMemSlotPtr:
  .res 2
.data
.export initMemSlotPtr
initMemSlotPtr:
  .res 2,0

.code
.export freeMemSlot
freeMemSlot:
  jmp (freeMemSlotPtr)

.export newMemSlot
newMemSlot:
  jmp (newMemSlotPtr)

.export popMemSlot
popMemSlot:
  jmp (popMemSlotPtr)

.export initMemSlot
initMemSlot:
  lda initMemSlotPtr
  bne :+
  lda initMemSlotPtr+1
  bne :+
  rts
:
  jmp (initMemSlotPtr)

backupSelectLookupFreeLo:
  .lobytes freeMemSlotDisk, freeMemSlotDisk, freeMemSlotDisk, freeMemSlotDisk, freeMemSlotReu, freeMemSlotGeoRam 
backupSelectLookupFreeHi:
  .hibytes freeMemSlotDisk, freeMemSlotDisk, freeMemSlotDisk, freeMemSlotDisk, freeMemSlotReu, freeMemSlotGeoRam 

backupSelectLookupNewLo:
  .lobytes newMemSlotDisk, newMemSlotDisk, newMemSlotDisk, newMemSlotDisk, newMemSlotReu, newMemSlotGeoRam 
backupSelectLookupNewHi:
  .hibytes newMemSlotDisk, newMemSlotDisk, newMemSlotDisk, newMemSlotDisk, newMemSlotReu, newMemSlotGeoRam 

backupSelectLookupPopLo:
  .lobytes popMemSlotDisk, popMemSlotDisk, popMemSlotDisk, popMemSlotDisk, popMemSlotReu, popMemSlotGeoRam 
backupSelectLookupPopHi:
  .hibytes popMemSlotDisk, popMemSlotDisk, popMemSlotDisk, popMemSlotDisk, popMemSlotReu, popMemSlotGeoRam 

backupSelectLookupInitLo:
  .lobytes initMemSlotDisk, initMemSlotDisk, initMemSlotDisk, initMemSlotDisk, initMemSlotReu, initMemSlotGeoRam 
backupSelectLookupInitHi:
  .hibytes initMemSlotDisk, initMemSlotDisk, initMemSlotDisk, initMemSlotDisk, initMemSlotReu, initMemSlotGeoRam 

.export backupSelect
backupSelect:
  lda #<backupSelectFrame
  ldx #>backupSelectFrame
  jsr _screenCpy

  select drawBackupSelect, drawBackupSelectSpace, selectedBackupSelect, 11, #6, {KEY_RETURN}, {keyReturnBackupSelect-1}

.export drawBackupSelect
drawBackupSelect:
  drawTable backupSelectNames, backupSelectScreenLo, backupSelectScreenHi,BACKUP_SELECT_WIDTH


.export drawBackupSelectSpace
drawBackupSelectSpace:
  drawSpace BACKUP_SELECT_WIDTH, backupSelectScreenLo, backupSelectScreenHi

.export keyReturnBackupSelect
keyReturnBackupSelect:
  ldx selectedBackupSelect

  lda backupSelectLookupFreeLo,x
  sta freeMemSlotPtr
  lda backupSelectLookupFreeHi,x
  sta freeMemSlotPtr+1

  lda backupSelectLookupNewLo,x
  sta newMemSlotPtr
  lda backupSelectLookupNewHi,x
  sta newMemSlotPtr+1

  lda backupSelectLookupPopLo,x
  sta popMemSlotPtr
  lda backupSelectLookupPopHi,x
  sta popMemSlotPtr+1

  lda backupSelectLookupInitLo,x
  sta initMemSlotPtr
  lda backupSelectLookupInitHi,x
  sta initMemSlotPtr+1

  txa
  clc
  adc #8
  sta backupDiskDrive

  jsr initMemSlot


  ;jsr backupCheck
  jmp selectSlot

.import __TMP_RAM_START__

backupCheckError1:
  jmp backupCheckError
.export backupCheck
backupCheck:
  lda #0
  sta slot

  lda #0
  sta $0400
:
    ldx slot
    stx $0403

    lda #ACTION_REFLASH
    sta action,x

    jsr newMemSlot

    lda slotPtr
    sta $0401
    lda slotPtr+1
    sta $0402
    cmp #>__TMP_RAM_START__
    bcc backupCheckError1
    cmp #>(__TMP_RAM_START__+$8000)
    bcs backupCheckError1

    lda slot
    ldx #$20
    ldy #0
:
      sta (slotPtr),y
      iny
      bne :-
      inc slotPtr+1
      dex
      bne :-

    inc slot
    lda slot
    cmp #10
    bne :--

  ldx #9
  jsr freeMemSlot
  ldx #8
  jsr freeMemSlot

:
    ldx slot
    stx $0403

    lda #ACTION_REFLASH
    sta action,x

    jsr newMemSlot

    lda slotPtr
    sta $0401
    lda slotPtr+1
    sta $0402
    cmp #>__TMP_RAM_START__
    bcc backupCheckError
    cmp #>(__TMP_RAM_START__+$8000)
    bcs backupCheckError

    lda slot
    ldx #$20
    ldy #0
:
      sta (slotPtr),y
      iny
      bne :-
      inc slotPtr+1
      dex
      bne :-

    inc slot
    lda slot
    cmp #14
    bne :--

  lda #0
  sta slot

  lda #1
  sta $0400
:
    ldx slot
    stx $0403

    jsr popMemSlot

    lda srcPtr
    sta $0401
    lda srcPtr+1
    sta $0402
    cmp #>__TMP_RAM_START__
    bcc backupCheckError
    cmp #>(__TMP_RAM_START__+$8000)
    bcs backupCheckError

    lda slot
    ldx #$20
    ldy #0
:
      cmp (srcPtr),y
      bne backupCheckError
      iny
      bne :-
      inc srcPtr+1
      dex
      bne :-

    inc slot
    lda slot
    cmp #8
    bne :--

  lda #0
  sta $d020
:
  jmp :-

backupCheckError:
  lda slotPtr
  sta $0404
  lda slotPtr+1
  sta $0405
  lda srcPtr
  sta $0406
  lda srcPtr+1
  sta $0407

  ldy #0
  lda (srcPtr),y
  sta $0408
:
  inc $d020
  jmp :-





