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
.include "assembler.inc"
.include "magicFlash64Lib.inc"
.include "c64Kernal.inc"
.include "zeropage.inc"
.include "status.inc"
.include "slot.inc"
.include "pla.inc"
.include "backup.inc"

.import __TMP_RAM_START__

.data

.export backupFileName
backupFileName:
  .byte "@0:tmp00"
backupFileNameDel:
  .byte "s:tmp00"

.export backupDiskDrive
backupDiskDrive:
  .byte 8
  



.code
bufferAddrLo:
  .lobytes (__TMP_RAM_START__+$0000)
  .lobytes (__TMP_RAM_START__+$2000)
  .lobytes (__TMP_RAM_START__+$4000)
  .lobytes (__TMP_RAM_START__+$6000)
  .lobytes (__TMP_RAM_START__+$8000)
bufferAddrHi:
  .hibytes (__TMP_RAM_START__+$0000)
  .hibytes (__TMP_RAM_START__+$2000)
  .hibytes (__TMP_RAM_START__+$4000)
  .hibytes (__TMP_RAM_START__+$6000)
  .hibytes (__TMP_RAM_START__+$8000)




.code
setBufferSrcSlotPtr:
  lda bufferAddrLo,y
  sta srcPtr
  lda bufferAddrHi,y
  sta srcPtr+1

setBufferSlotPtr:
  lda bufferAddrLo,x
  sta slotPtr
  lda bufferAddrHi,x
  sta slotPtr+1
  rts
  
setBufferSrcPtr:
  lda bufferAddrLo,x
  sta srcPtr
  lda bufferAddrHi,x
  sta srcPtr+1
  rts
  
.export freeMemSlotDisk
freeMemSlotDisk:
  txa
  ldy #4
:
    cmp bufferSlot,y
    beq :+
    dey
    bpl :-
  rts
:
  lda #$ff
  sta bufferSlot,y
  rts

  
.export popMemSlotDisk
popMemSlotDisk:
  txa

  ldx #0
:
    cmp bufferSlot,x
    bne :+
      jsr setBufferSrcPtr
      jmp popMemSlotFound
:
    inx
    cpx #5
    bne :--

  ;check action
  ldx slot
  lda action,x
  and #ACTION_REFLASH
  beq popMemSlotFile
    jsr newMemSlotDisk
    jsr setBufferSrcPtr
    ldx slot
    jsr loadTmp
    ldx slot
    jmp freeMemSlotDisk

.export popMemSlotFound
popMemSlotFound:
    cpx #4
    bne :+
      ldy #0
      ldx #4
      jsr setBufferSrcSlotPtr
      jsr plaKernalOffIoOff
      jsr swapSlot
      jsr plaKernalIoOn


      lda bufferSlot
      sta bufferSlot+4
      lda slot
      sta bufferSlot
      
      ldx #0
      jsr setBufferSrcPtr
:
    ldx slot
    jmp freeMemSlotDisk

.export popMemSlotFile
popMemSlotFile:
  jmp reloadSlot


.export initMemSlotDisk
initMemSlotDisk:
  ldx #4
  lda #$ff
:
  sta bufferSlot,x
  dex
  bpl :-
  rts



  
  

.export newMemSlotDisk
newMemSlotDisk:
  stx tmp6

  ; check if slot already exists
  txa
  ldx #0
:
  cmp bufferSlot,x
  bne :+
    jmp newMemSlotFound
:
  inx
  cpx #5
  bne :--

  ; search for free mem
  ldx #0
  lda #$ff
:
  cmp bufferSlot,x
  beq newMemSlotFound
  inx
  cpx #5
  bne :-

  ; search for non reflash slot (not backup)
  ldx #0
:
  ldy bufferSlot,x
  lda action,y
  and #ACTION_REFLASH
  beq newMemSlotFound

  inx
  cpx #5
  bne :-


  ; save 1st
  ldx bufferSlot
  lda slotDigit0,x
  sta backupFileName+6
  sta backupFileNameDel+5
  lda slotDigit1,x
  sta backupFileName+7
  sta backupFileNameDel+6
newMemSlotSave:
  lda backupDiskDrive
  ldx #<backupFileName
  ldy #>backupFileName
  jsr KERNAL_SETNAM

  lda #1
  ldx backupDiskDrive
  ldy #1
  jsr KERNAL_SETLFS

  ldy #0
  ldx #1
  jsr setBufferSrcSlotPtr
  ldx slotPtr
  ldy slotPtr+1
  lda #srcPtr
  jsr KERNAL_SAVE
  bcs newMemSlotSaveError
    jsr checkError
    bcs newMemSlotSaveError

newMemSlotSaveDone:
      sei

      ldx #0
newMemSlotFound:
      cpx #4
      bne :+

        lda bufferSlot
        sta bufferSlot+4

        jsr plaKernalOffIoOff

        ldy #0
        ldx #4
        jsr setBufferSrcSlotPtr

        jsr copySlot


        jsr plaKernalIoOn
        ldx #0

:
      lda tmp6
      sta bufferSlot,x

      jmp setBufferSlotPtr
      
newMemSlotSaveError:
    ; delete file after error
    lda #7
    ldx #<backupFileNameDel
    ldy #>backupFileNameDel
    jsr KERNAL_SETNAM     ; call SETNAM

    lda #$0F      ; file number 15
    ldx backupDiskDrive
    ldy #$0F      ; secondary address 15
    jsr KERNAL_SETLFS     ; call SETLFS

    jsr KERNAL_OPEN     ; call OPEN

    lda #$0F      ; filenumber 15
    jsr KERNAL_CLOSE     ; call CLOSE

    jsr KERNAL_CLRCHN     ; call CLRCHN

    jsr printStatusWrBackupError

    ; show status
    ldx slot
    jsr printStatusBackup

    jmp newMemSlotSave



loadTmp:
  ; load tmp
  lda slotDigit0,x
  sta backupFileName+6
  sta backupFileNameDel+5
  lda slotDigit1,x
  sta backupFileName+7
  sta backupFileNameDel+6
loadTmpRetry:
  lda #5
  ldx #<(backupFileName+3)
  ldy #>(backupFileName+3)
  jsr KERNAL_SETNAM

  lda #1
  ldx backupDiskDrive
  ldy #0
  jsr KERNAL_SETLFS
  
  lda #0
  ldx slotPtr
  ldy slotPtr+1
  jsr KERNAL_LOAD
  bcs loadTmpError
    jsr checkError
    bcs loadTmpError
loadTmpDone:
      lda #7
      ldx #<backupFileNameDel
      ldy #>backupFileNameDel
      jsr KERNAL_SETNAM     ; call SETNAM

      lda #$0F      ; file number 15
      ldx backupDiskDrive
      ldy #$0F      ; secondary address 15
      jsr KERNAL_SETLFS     ; call SETLFS

      jsr KERNAL_OPEN     ; call OPEN

      lda #$0F      ; filenumber 15
      jsr KERNAL_CLOSE     ; call CLOSE

      jsr KERNAL_CLRCHN     ; call CLRCHN
      sei
      rts


loadTmpError:
  jsr printStatusRdRestoreError

  ; show status
  ldx slot
  jsr printStatusRestore

  jmp loadTmpRetry





.export checkError
checkError:
  lda #0
  jsr KERNAL_SETNAM     ; call SETNAM

  lda #$0F      ; file number 15
  ldx backupDiskDrive
  ldy #$0F      ; secondary address 15
  jsr KERNAL_SETLFS     ; call SETLFS

  jsr KERNAL_OPEN     ; call OPEN

  ldx #15
  jsr KERNAL_CHKIN

  jsr KERNAL_CHRIN
  asl
  asl
  asl
  asl
  sta tmp1
  jsr KERNAL_CHRIN
  and #$0f
  ora tmp1
  sta tmp1


  lda #$0F      ; filenumber 15
  jsr KERNAL_CLOSE     ; call CLOSE

  jsr KERNAL_CLRCHN     ; call CLRCHN
  sei

  lda tmp1
  cmp #$20
  rts

