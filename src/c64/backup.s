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

.include "backupDisk.inc"
.include "status.inc"
.include "slot.inc"
.include "magicFlash64Lib.inc"
.include "zeropage.inc"
.include "c64Kernal.inc"

;incBegin
.import popMemSlot
.import newMemSlot
.import freeMemSlot
;incEnd

.data
openReloadSlot:
  .byte $ff

.bss
.export bufferSlot
bufferSlot:
  .res 64

.code

.export backupSlot
backupSlot:
  ; print status
  jsr printStatusBackup

  ; get memory for slot
  ldx slot
  jsr newMemSlot

  ; activate slot
  lda slot
  jsr _ekSelect

  ; set srcPtr to Kernal Address
  lda #$00
  sta srcPtr
  lda #$e0
  sta srcPtr+1


  ; copy kernal to buffer
  jsr copySlot

  ; activate kernal
  lda activeKernalSlot
  jsr _ekSelect
  
  rts

.export restoreSlot
restoreSlot:
  ; print status
  jsr printStatusRestore
  
  ; get slot
  ldx slot
  jmp popMemSlot


.export copySlot
copySlot:
  ldy #0
  ldx #$20
:
  lda (srcPtr),y
  sta (slotPtr),y
  iny
  bne :-
  inc srcPtr+1
  inc slotPtr+1
  dex
  bne :-
  rts

.export swapSlot
swapSlot:
  ldy #0
  ldx #$20
  stx tmp5
:
  lda (srcPtr),y
  tax
  lda (slotPtr),y
  sta (srcPtr),y
  txa
  sta (slotPtr),y
  iny
  bne :-
  inc srcPtr+1
  inc slotPtr+1
  dec tmp5
  bne :-
  rts


.export reloadSlot
reloadSlot:
  jsr printStatusLoadSlot

  ldx slot
  lda slotDescrType,x
  cmp #$40
  bcs :+
    lda slotDescrType,x
    tax
:
  stx tmp6

  ; check if slot open
  lda openReloadSlot
  cmp #$ff
  beq reloadSlotFileOpen
    cmp tmp6
    bne reloadSlotFileClose
      ldx slot
      lda slotDescrSizeHi,x
      cmp size+1
      bcc reloadSlotContRead
      bne reloadSlotFileClose
        lda size
        cmp slotDescrSizeLo,x
        bcs reloadSlotContRead


    
    ; check for different slot or size smaller->close
    ; open
    

reloadSlotFileClose:
  jsr reloadSlotClose






reloadSlotFileOpen:




  ; check slot type (first slot of file or follow up)
  ldx tmp6
  ; set size
  lda slotDescrSizeLo,x
  sta size
  lda slotDescrSizeHi,x
  sta size+1

  stx openReloadSlot
    
reloadSlotFileOpenRetry:
    jsr setSlotPtrFn
    lda fnLenSlot,x
    ldx slotPtr
    ldy slotPtr+1
    jsr KERNAL_SETNAM

    ldx tmp6
    lda fnDrive,x
    tax
    lda #2
    ldy #2
    jsr KERNAL_SETLFS

    jsr KERNAL_OPEN
    bcc reloadSlotFileOpenDone
      ldx slot
      jsr printStatusLoadingErrorSlot
      ldx tmp6
      jmp reloadSlotFileOpenRetry


reloadSlotFileOpenDone:
    ldx #2
    jsr KERNAL_CHKIN

.export reloadSlotContRead
reloadSlotContRead:
  ldx slot
  jsr printStatusLoadSlot
reloadSlotContRead2:
  ldx slot
  lda slotDescrSizeLo,x
  cmp size
  bne reloadSlotSkip
  lda slotDescrSizeHi,x
  cmp size+1
  beq reloadSlotNoSkip

reloadSlotSkip:

    jsr KERNAL_READST
    bne reloadSlotError

    jsr KERNAL_CHRIN

    lda size
    bne :+
      dec size+1
:
    dec size
    jmp reloadSlotContRead2

reloadSlotNoSkip:
    ldx slot
    jsr newMemSlot
    lda slotPtr
    sta srcPtr
    lda slotPtr+1
    sta srcPtr+1

    ldy #0
    ldx #$20
    stx len
reloadSlotReadLoop:
    jsr KERNAL_READST
    bne reloadSlotError

    jsr KERNAL_CHRIN
    sta (slotPtr),y

    lda size
    bne :+
      dec size+1
:
    dec size

    iny
    bne reloadSlotReadLoop

    inc slotPtr+1
    dec len
    bne reloadSlotReadLoop

    sei
    

reloadSlotFound:
    ; fill up remaining slot with $ff
    ldx slot
    lda len
    beq :++
    ldy slotDescrSizeLo,x
    lda #$ff
:
    sta (slotPtr),y
    iny
    bne :-
    inc slotPtr+1
    dec len
    bne :-
:
    ; free slot
    jmp freeMemSlot

reloadSlotError:
    and #$bf
    beq reloadSlotEof
      jsr reloadSlotClose

      ; free up slot
      ldx slot
      jsr freeMemSlot

      jsr printStatusLoadingErrorSlot

      ldx slot
      jmp reloadSlot
reloadSlotEof:
  jsr reloadSlotClose
  jmp reloadSlotFound
      

.export reloadSlotClose
reloadSlotClose:
  lda openReloadSlot
  cmp #$ff
  beq :+
    lda #2
    jsr KERNAL_CLOSE

    jsr KERNAL_CLRCHN

    sei
    
    lda #$ff
    sta openReloadSlot
:
  rts
    
