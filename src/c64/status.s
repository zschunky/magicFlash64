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

.include "key.inc"
.include "assembler.inc"
.include "textProgrammerEn.inc"
.include "screenCpy.inc"
.include "slot.inc"
.include "frame.inc"

;incBegin
.macro statusText label,text1,text2,text3
.export label
label:
  frameAddrTitle STATUS_WIDTH+2, 5
  .byte $f1
  scrcode text1
  .ifnblank text2
    .export .ident(.concat(.string(label),"1"))
    .ident(.concat(.string(label),"1")):
    scrcode text2
  .endif
  .ifnblank text3
    .export .ident(.concat(.string(label),"2"))
    .ident(.concat(.string(label),"2")):
    scrcode text3
  .endif

  .ifnblank text3
    .if STATUS_WIDTH-.strlen(.concat(text1,text2,text3))=1
       .byte $20
    .elseif STATUS_WIDTH-.strlen(.concat(text1,text2,text3))=2
       .byte $20,$20
    .elseif STATUS_WIDTH-.strlen(.concat(text1,text2,text3))>2
       .byte $80+STATUS_WIDTH-.strlen(.concat(text1,text2,text3)),$20
    .endif
  .else
    .ifnblank text2
      .if STATUS_WIDTH-.strlen(.concat(text1,text2))=1
         .byte $20
      .elseif STATUS_WIDTH-.strlen(.concat(text1,text2))=2
         .byte $20,$20
      .elseif STATUS_WIDTH-.strlen(.concat(text1,text2))>2
         .byte $80+STATUS_WIDTH-.strlen(.concat(text1,text2)),$20
      .endif
    .else
      .if STATUS_WIDTH-.strlen(text1)=1
         .byte $20
      .elseif STATUS_WIDTH-.strlen(text1)=2
         .byte $20,$20
      .elseif STATUS_WIDTH-.strlen(text1)>2
         .byte $80+STATUS_WIDTH-.strlen(text1),$20
      .endif
    .endif
  .endif
    
  .byte $80
.endmacro
;incEnd

.export printStatusErrorPgmErsActKernal
printStatusErrorPgmErsActKernal:
  lda #<statusErrorPgmErsActKernal
  ldx #>statusErrorPgmErsActKernal
  jmp statusSpace

.export printStatusCheckSlot
printStatusCheckSlot:
  ; set slot number in status
  lda slotDigit0,x
  sta statusCheckSlot1
  lda slotDigit1,x
  sta statusCheckSlot1+1

  lda #<statusCheckSlot
  ldx #>statusCheckSlot
  jmp _screenCpy

.export printStatusUnexpErase
printStatusUnexpErase:
  ; set slot number in status
  lda slotDigit0,x
  sta statusUnexpErase1
  lda slotDigit1,x
  sta statusUnexpErase1+1

  lda #<statusUnexpErase
  ldx #>statusUnexpErase
  jmp statusSpace

.export printStatusUnexpCrc
printStatusUnexpCrc:
  ; set slot number in status
  lda slotDigit0,x
  sta statusUnexpCrc1
  lda slotDigit1,x
  sta statusUnexpCrc1+1

  lda #<statusUnexpCrc
  ldx #>statusUnexpCrc
  jmp statusSpace

.export printStatusErrorPgm
printStatusErrorPgm:
  ; set slot number in status
  lda slotDigit0,x
  sta statusErrorPgm1
  lda slotDigit1,x
  sta statusErrorPgm1+1

  lda #<statusErrorPgm
  ldx #>statusErrorPgm
  jmp statusSpace

.export printStatusErrorErase
printStatusErrorErase:
  ; set slot number in status
  lda slotDigit0,x
  sta statusErrorErase1
  lda slotDigit1,x
  sta statusErrorErase1+1

  txa
  clc
  adc #7
  tax
  lda slotDigit0,x
  sta statusErrorErase2
  lda slotDigit1,x
  sta statusErrorErase2+1

  lda #<statusErrorErase
  ldx #>statusErrorErase
  jmp statusSpace

.export printStatusErase
printStatusErase:
  ; set slot number in status
  lda slotDigit0,x
  sta statusErase1
  lda slotDigit1,x
  sta statusErase1+1

  txa
  clc
  adc #7
  tax
  lda slotDigit0,x
  sta statusErase2
  lda slotDigit1,x
  sta statusErase2+1

  lda #<statusErase
  ldx #>statusErase
  jmp _screenCpy

.export printStatusLoadingErrorSlot
printStatusLoadingErrorSlot:
  ; set slot number in status
  lda slotDigit0,x
  sta statusLoadingErrorSlot1
  lda slotDigit1,x
  sta statusLoadingErrorSlot1+1

  lda #<statusLoadingErrorSlot
  ldx #>statusLoadingErrorSlot
  jmp statusSpace

.export printStatusWrBackupError
printStatusWrBackupError:
  lda #<statusWrBackupError
  ldx #>statusWrBackupError
  jmp statusSpace

.export printStatusRdRestoreError
printStatusRdRestoreError:
  lda #<statusRdRestoreError
  ldx #>statusRdRestoreError
  jmp statusSpace

.export printStatusLoadSlot
printStatusLoadSlot:
  ; set status
  lda slotDigit0,x
  sta statusLoading1
  lda slotDigit1,x
  sta statusLoading1+1
  lda #<statusLoading
  ldx #>statusLoading
  jmp _screenCpy
  
.export printStatusFrame
printStatusFrame:
  lda #<statusFrame
  ldx #>statusFrame
  jmp _screenCpy

.export printStatusLoadingDir
printStatusLoadingDir:
  lda #<statusLoadingDir
  ldx #>statusLoadingDir
  jmp _screenCpy

.export printStatusNotEnoughFree
printStatusNotEnoughFree:
  lda #<statusNotEnoughFree
  ldx #>statusNotEnoughFree
  jmp statusSpace

.export printStatusLoadingError
printStatusLoadingError:
  lda #<statusLoadingError
  ldx #>statusLoadingError
  jmp statusSpace

.export printStatusProgram
printStatusProgram:
  lda slotDigit0,x
  sta statusProgram1
  lda slotDigit1,x
  sta statusProgram1+1
  lda #<statusProgram
  ldx #>statusProgram
  jmp _screenCpy

.export printStatusReProgram
printStatusReProgram:
  lda slotDigit0,x
  sta statusReProgram1
  lda slotDigit1,x
  sta statusReProgram1+1
  lda #<statusReProgram
  ldx #>statusReProgram
  jmp _screenCpy

.export printStatusRestore
printStatusRestore:
  lda slotDigit0,x
  sta statusRestore1
  lda slotDigit1,x
  sta statusRestore1+1
  lda #<statusRestore
  ldx #>statusRestore
  jmp _screenCpy

.export printStatusBackup
printStatusBackup:
  lda slotDigit0,x
  sta statusBackup1
  lda slotDigit1,x
  sta statusBackup1+1
  lda #<statusBackup
  ldx #>statusBackup
  jmp _screenCpy

statusSpace:
  jsr _screenCpy
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-
  rts
