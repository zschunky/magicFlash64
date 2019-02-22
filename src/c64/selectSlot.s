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
.include "select.inc"
.include "magicFlash64Lib.inc"
.include "magicFlash64LibPgm.inc"
.include "crc.inc"
.include "magicFlash64Colors.inc"
.include "slot.inc"
.include "backup.inc"
.include "status.inc"
.include "textProgrammerEn.inc"
.include "patchTable.inc"
.include "backup.inc"
.include "zeropage.inc"
.include "selectFile.inc"
.include "screenCpy.inc"
.include "qrcode.inc"
.macpack cbm

.define SELECT_LEN 38

.data
.export selectedType
selectedType:
  .res 1

.code

.export selectSlot
selectSlot:
  lda #<slotScreen
  ldx #>slotScreen
  jsr _screenCpy
  select drawSlot, drawSlotSpace, selectedSlot, 20, #64, {KEY_E,KEY_P,KEY_F7,KEY_V,KEY_B,KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_U,KEY_D,KEY_T,KEY_F1}, {keyE-1,keyP-1,keyF7-1,keyV-1,keyB-1,keyNum0-1,keyNum1-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum-1,keyNum8-1,keyNum9-1,keyU-1,keyD-1,selectType-1,keyF1-1}

;slotCheck:
;  jsr setSlotPtr
;  ldy #0
;  lda slotType
;  bmi :+
;  cmp (slotPtr),y
;  rts
;:
;  lda #0
;  rts

drawSlotSpace:
  ldx screenItem
  lda selectSlotScreenLo,x
  sta screenPtr
  lda selectSlotScreenHi,x
  sta screenPtr+1
  
  ldy #SELECT_LEN-1
  lda #32
:
  sta (screenPtr),y
  dey
  bpl :-
  rts

drawSlot:
  ldx screenItem
  lda selectSlotScreenLo,x
  sta screenPtr
  lda selectSlotScreenHi,x
  sta screenPtr+1

  ldx drawItem

  ldy #0
  lda slotDigit0,x
  eor inverse
  sta (screenPtr),y

  lda slotDigit1,x
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda #45
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda action,x
  and #ACTION_ERASE
  beq :+
  lda #69
  .byte $2c
:
  lda #32
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda action,x
  and #ACTION_PROGRAM
  bne :+
  lda action,x
  and #ACTION_REFLASH
  bne :++
  lda #32
  jmp :+++
:
  lda #80
  .byte $2c
:
  lda #82
:
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda #45
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y


  jsr setSlotPtrName
  lda slotDescrType,x
  cmp #$ff
  bne :+
  lda #69
  sec
  bne :+++
:
  cmp #$40
  bcs :+
    lda #$2b
    clc
    bcc :++
:
  sec
  sbc #$40
  tax
  lda types,x
  clc
:
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  lda #45
  eor inverse
  inc screenPtr
  bne :+
  inc screenPtr+1
:
  sta (screenPtr),y

  inc screenPtr
  bne :+
  inc screenPtr+1
:
  bcs :++
  
:
  lda (slotPtr),y
  eor inverse
  sta (screenPtr),y
  iny
  cpy #16
  bne :-

:
  lda #$20
  eor inverse
:
  sta (screenPtr),y
  iny
  cpy #30
  bne :-

  ldx screenItem
  lda selectSlotScreenLo,x
  sta screenPtr
  lda selectSlotScreenHi,x
  clc
  adc #$d4
  sta screenPtr+1

  lda #COLOR_SELECTED
  ldx drawItem
  cpx defaultSlot
  beq drawColor
    lda slotDescrType,x
    cmp #$ff
    bne :+
      lda #COLOR_EMPTY
      jmp drawColor
:
    cmp #$40
    bcs :+
      lda #COLOR_FOLLOWUP
      jmp drawColor
:
    sec
    sbc #$40
    tax
    lda colorTypes,x

drawColor:
  ldy #37
:
    sta (screenPtr),y
    dey
    bpl :-

  rts

.export keyD
keyD:
  lda selectedSlot
  sta defaultSlot
  jsr _ekSetDefault
  
  jmp selectSlot

.export keyU
keyU:
  jsr slotInit
  lda #0
  sta keyNumPos
  jmp selectSlot

.export keyV
keyV:
  ; select kernal slot
  lda selectedSlot
  jsr _ekSelect
  
  ldx #0
:
  lda $e000,x
  sta $0400,x
  lda $e100,x
  sta $0500,x
  lda $e200,x
  sta $0600,x
  lda $e300,x
  sta $0700,x
  lda #1
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne :-

  lda activeKernalSlot
  jsr _ekSelect

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  jmp selectSlot

.export selectType
selectType:
  ldx selectedSlot
  lda slotDescrType,x
  cmp #$40
  bcs :+
    rts
:
  cmp #$ff
  bne :+
    lda #$40
    cpx #0
    beq :+
      lda #$41
:
  sec
  sbc #$40
  sta selectedType


  lda #<typeFrame
  ldx #>typeFrame
  jsr _screenCpy

  select drawType, drawTypeSpace, selectedType, 7, #5, {KEY_RETURN, KEY_STOP}, {keyReturnType-1, selectSlot-1}, checkType

.export drawType
drawType:
  drawTable typesName, typeScreenLo, typeScreenHi, TYPE_WIDTH


.export drawTypeSpace
drawTypeSpace:
  drawSpace TYPE_WIDTH, typeScreenLo, typeScreenHi

.export keyReturnType
keyReturnType:
  ldx selectedSlot
  lda slotDescrType,x
  cmp #$ff
  bne :++
    jsr setSlotPtrName
    lda #$20
    ldy #15
:
      sta(slotPtr),y
      dey
      bpl :-
    
:

  lda selectedType
  clc
  adc #$40


  cmp slotDescrType,x
  beq :+
    sta slotDescrType,x

    ldx #BOOT_SLOT
    jsr markEraseBlock
:
  jmp selectSlot

.export checkType
checkType:
  lda selectedSlot

  ; check for basic
  cpx #0
  bne :+
    cmp #0
    rts
:
  ; check for cart 
  cpx #3
  bne :+
    lda #1
    rts
:
  ; check for memory
  cpx #4
  bne :+
    cmp #BOOT_SLOT
    rts
:
  lda #0
  rts
  

.export keyE
keyE:
  ldx selectedSlot
  cpx activeKernalSlot
  bne :+
    jsr printStatusFrame
    jsr printStatusErrorPgmErsActKernal
    jmp selectSlot
:
  cpx #BOOT_SLOT
  beq :+
    ldx #BOOT_SLOT
    jsr markEraseBlock
:
  ldx selectedSlot
  jsr eraseSlot

  jmp selectSlot

.export keyB
keyB:
  lda selectedSlot
  jsr _ekSelect
  jsr _ekReset
  jmp selectSlot

.export keyP
keyP:
  lda selectedSlot
  cmp activeKernalSlot
  bne :+
    jsr printStatusFrame
    jsr printStatusErrorPgmErsActKernal
    jmp selectSlot
:
  jmp selectFile
  
.export keyNum8
keyNum8:
  lda #8
  jmp drive

.export keyNum9
keyNum9:
  lda #9
  jmp drive

.export keyNum0
keyNum0:
  lda #10
  jmp drive

.export keyNum1
keyNum1:
  lda #11

drive:
  sta tmp2
  sty tmp1
  ldax #KEY2MASK(KEY_CBM)
  jsr isKeyDown
  beq :+
    ldy tmp1
    jmp keyNum
:
  lda tmp2
  sta selectedDrive
  lda #0
  sta keyNumPos
  rts


.export keyNum
keyNum:
  inc keyNumPos

  lda keyLast
  jsr getNumKey
  cpy #10
  bne :+++
:
    lda #1
    sta keyNumPos
:
    rts
:
  lda keyNumPos
  cmp #2
  bne :--


  tya
  asl a
  sta tmp1
  asl a
  asl a
  clc
  adc tmp1
  sta tmp1
  
  txa
  jsr getNumKey
  tya
  clc
  adc tmp1

  cmp #64
  bcs :---

  sta selectedSlot

  lda #0
  sta keyNumPos

  jmp selectSlot



getNumKey:
  ldy #0
:
  cmp numberKeys,y
  beq :+
  iny
  cpy #10
  bne :-
:
  rts

.bss
.export keyNumPos
keyNumPos:
  .byte 0

.code
numberKeys:
  .byte KEY_0; 0
  .byte KEY_1; 1
  .byte KEY_2; 2
  .byte KEY_3; 3
  .byte KEY_4; 4
  .byte KEY_5; 5
  .byte KEY_6; 6
  .byte KEY_7; 7
  .byte KEY_8; 8 
  .byte KEY_9; 9
  
.export keyF7
keyF7:
  jsr printStatusFrame

  ; loop over erase block
  lda #0
  sta eraseBlock
eraseBlockLoop:
    ; check for erase
    tax
    lda action,x
    and #ACTION_ERASE
    bne :+
      jmp eraseBlockLoopNext
:
      ; check if active kernal is part of this eraseBlock
      lda activeKernalSlot
      and #$38
      cmp eraseBlock
      bne backupLoop

        ldx activeKernalSlot
        stx slot

        ; backup slot
        jsr backupSlot

        ldx eraseBlock

      ; loop over slots to for backing up
backupLoop:
        ; skip if active kernal slot
        cpx activeKernalSlot
        beq backupLoopInc

          ; check if slot needs backup
          lda action,x
          and #ACTION_REFLASH
          beq backupLoopInc
            stx slot

            ; backup slot
            jsr backupSlot
            ldx slot

backupLoopInc:
        inx
        txa
        and #7
        bne backupLoop
    
      ; set slot number in status
      ldx eraseBlock
      jsr printStatusErase

      ; activare erase block
      lda eraseBlock
      jsr _ekSelect

      ; erase
      jsr _ekWrErase

      ; select active kernal
      lda activeKernalSlot
      jsr _ekSelect

      ;check for erase error
      lda _ekError
      beq :+
        ldx eraseBlock
        jsr printStatusErrorErase
:

      ; check if active kernal is part of this eraseBlock
      lda activeKernalSlot
      and #$38
      cmp eraseBlock
      bne restoreLoopStart

        ldx activeKernalSlot
        stx slot

        ; restore slot
        jsr restoreSlot

        ; patch slot table if required
        jsr patchTable

        ; set status
        ldx slot
        jsr printStatusReProgram

        ; activate slot
        lda slot
        jsr _ekSelect

        ; pgm
        lda srcPtr
        ldx srcPtr+1
        jsr _ekWrProgram

        ; activate kernal slot
        lda activeKernalSlot
        jsr _ekSelect

        ; check for pgm error
        lda _ekError
        beq :+
          ldx slot
          jsr printStatusErrorPgm
          lda #0
:
restoreLoopStart:
      ; loop over slots to restore backups
      ldx eraseBlock
restoreLoop:
        ; skip if active kernal slot
        cpx activeKernalSlot
        beq restoreLoopInc

          ; check if slot needs backup
          lda action,x
          and #ACTION_REFLASH
          beq restoreLoopInc
            ; activate slot
            stx slot

            ; restore slot
            jsr restoreSlot

            ; patch slot table if required
            jsr patchTable
    
            ; set status
            ldx slot
            jsr printStatusReProgram
            ; activate slot
            lda slot
            jsr _ekSelect

            ; pgm
            lda srcPtr
            ldx srcPtr+1
            jsr _ekWrProgram

            ; activate kernal slot
            lda activeKernalSlot
            jsr _ekSelect

            ; check for pgm error
            lda _ekError
            beq :+
              ldx slot
              jsr printStatusErrorPgm
              lda #0
:

            ldx slot

      
restoreLoopInc:
        inx
        txa
        and #7
        bne restoreLoop
eraseBlockLoopNext:
    ; increment erase block
    lda eraseBlock
    clc
    adc #8
    sta eraseBlock
    cmp #64
    beq eraseBlockLoopDone
    jmp eraseBlockLoop

eraseBlockLoopDone:






  ; loop over slots to for programming
  ldx #0
pgmLoop:

    ; check if slot needs to be programmed
    lda action,x
    and #ACTION_PROGRAM
    beq :+
    lda slotDescrType,x
    and #$40
    bne :++
:
      jmp pgmLoopInc
:
      ; remember slot
      stx slotTmp
      jmp :+
pgmInnerLoop:
        lda slotDescrType,x
        cmp slotTmp
        bne pgmInnertLoopInc
:
          ; get slot
          stx slot
          jsr popMemSlot

          ; select slot for programming
          lda slot
          jsr _ekSelect

          ; patch slot table if required
          jsr patchTable

          ; set status
          ldx slot
          jsr printStatusProgram

          ; pgm
          lda srcPtr
          ldx srcPtr+1
          jsr _ekWrProgram

          ; activate kernal
          lda activeKernalSlot
          jsr _ekSelect

          ; check for pgm erro
          lda _ekError
          beq :+
            ldx slot
            jsr printStatusErrorPgm
            lda #0
:

          ldx slot
pgmInnertLoopInc:
        inx
        cpx #$40
        beq :+
        jmp pgmInnerLoop
:
    jsr reloadSlotClose
    ldx slotTmp

pgmLoopInc:
    inx
    cpx #$40
    beq :+
    jmp pgmLoop
:


  ; activate kernal
  lda activeKernalSlot
  jsr _ekSelect

  jsr slotInit
  lda #0
  sta keyNumPos

  jmp selectSlot


pgmFileError:
  inc VIC_BORDERCOLOR
  jmp pgmFileError


.export keyF1
keyF1:
  lda #<helpFrame
  ldx #>helpFrame
  jsr _screenCpy

  lda #<help1
  ldx #>help1
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help2
  ldx #>help2
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help3
  ldx #>help3
  jsr _screenCpy

:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  lda #<help4
  ldx #>help4
  jsr _screenCpy
  ldx #14
:
  .repeat 15,i
     lda qrcode +i*15,x
     sta $0400+20+(i+4)*40,x
  .endrepeat
     dex
     bpl :-


:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  beq :-

  ldy #16
  ldx #0
:
  inx
  bne :-
  dey
  bne :-
:
  ldax #KEY2MASK(KEY_SPACE)
  jsr isKeyDown
  bne :-

  jmp selectSlot

colorTypes:
  .byte COLOR_BASIC, COLOR_KERNAL, COLOR_PRG, COLOR_CART, COLOR_MENU
types:
  scrcode "BKPCM"
selectSlotScreenLo:
  .repeat 20,i
    .lobytes $0400+(i+4)*40+1
  .endrepeat
selectSlotScreenHi:
  .repeat 20,i
    .hibytes $0400+(i+4)*40+1
  .endrepeat
