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
.include "crc.inc"
.include "c64Kernal.inc"
.include "backup.inc"
.include "status.inc"
.include "slot.inc"
.include "zeropage.inc"
.include "selectSlot.inc"
.include "petscii2screen.inc"
.include "screenCpy.inc"
.include "textProgrammerEn.inc"




.define NUM_FILES 256


.zeropage
.exportzp selectedFile
selectedFile:
  .res 1
.exportzp numFiles
numFiles:
  .res 1
.exportzp dirPtr
dirPtr:
  .res 2


.data
.export selectedDrive
selectedDrive:
  .byte 8

.bss
oldType:
  .res 1

.code
.export selectFile
selectFile:
  ldx #$ff
  jsr newMemSlot
  lda slotPtr
  sta dirPtr
  lda slotPtr+1
  sta dirPtr+1



  lda #0
  sta numFiles

  jsr printStatusFrame
  jsr printStatusLoadingDir

        LDA #1
        LDX #<dirName
        LDY #>dirName
        JSR KERNAL_SETNAM     ; call SETNAM

        LDA #$02      ; file number 2
        ;LDX $BA       ; last used device number
        ;BNE :+
        LDX selectedDrive      ; default to device 8
        LDY #$00      ; secondary address 2
        JSR KERNAL_SETLFS     ; call SETLFS

        JSR KERNAL_OPEN     ; call OPEN
        bcc :+
        jmp error    ; if carry set, the file could not be opened
:

        ; check drive error channel here to test for
        ; FILE NOT FOUND error etc.

        LDX #$02      ; filenumber 2
        JSR KERNAL_CHKIN     ; call CHKIN (file 2 now used as input)

        ; skip 6 bytes
        LDY #$06
:       JSR KERNAL_READST     ; call READST (read status byte)
        beq :+
        jmp eof      ; either EOF or read error
:
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        dey
        bne :--        ; next byte

        ; skip till 0 byte
:       JSR KERNAL_READST     ; call READST (read status byte)
        beq :+
        jmp eof      ; either EOF or read error
:
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        cmp #0
        bne :--       ; next byte


getFile:
        ; skip 2 bytes
        LDY #$02
:       JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        dey
        bne :-        ; next byte

        ; get lo size
        JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        ldy #16
        sta (slotPtr),y

        ; get hi size
        JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        iny
        sta (slotPtr),y

        ; search for "
:       JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        cmp #0
        beq getFile ; next byte
        cmp #$22
        bne :-

        ; save fn
        ldy #0
:       JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        cmp #0
        beq getFile ; next byte
        cmp #$22
        beq :+
        sta (slotPtr),y
        iny
        jmp :-
:
        tya
        ldy #18
        sta (slotPtr),y

        ; skip till type
:       JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        cmp #0
        beq getFile ; next byte
        cmp #$20
        beq :-

        ; check for PRG (only first letter)
        cmp #80
        bne :+

        inc numFiles
        lda slotPtr
        clc
        adc #32
        sta slotPtr
        bcc :+
        inc slotPtr+1
:
        ; skip till end of entry
:       JSR KERNAL_READST     ; call READST (read status byte)
        BNE eof      ; either EOF or read error
        JSR KERNAL_CHRIN     ; call CHRIN (get a byte from file)
        cmp #0
        bne :-
        JMP getFile    ; next byte

eof:
readerror:
error:
close:
        LDA #$02      ; filenumber 2
        JSR KERNAL_CLOSE     ; call CLOSE

        JSR KERNAL_CLRCHN     ; call CLRCHN

  sei
  lda numFiles
  bne :+
  jmp selectSlot
:
  jsr selectSlot
  lda #0
  sta selectedFile
  ldx selectedSlot
  lda slotDigit0,x
  sta dirScreen+32
  lda slotDigit1,x
  sta dirScreen+33
  lda #<dirScreen
  ldx #>dirScreen
  jsr _screenCpy

  jmp :+

:
  select drawFile, drawFileSpace, selectedFile, 17, numFiles, {KEY_RETURN, KEY_STOP, KEY_8, KEY_9, KEY_0, KEY_1}, {keyFileReturn-1, selectSlot-1, keyFile8-1, keyFile9-1, keyFile0-1, keyFile1-1}

.export keyFile8
keyFile8:
  jsr selectSlot

  lda #8
  sta selectedDrive
  
  jmp selectFile

.export keyFile9
keyFile9:
  jsr selectSlot

  lda #9
  sta selectedDrive
  
  jmp selectFile

.export keyFile0
keyFile0:
  jsr selectSlot

  lda #10
  sta selectedDrive
  
  jmp selectFile

.export keyFile1
keyFile1:
  jsr selectSlot

  lda #11
  sta selectedDrive
  
  jmp selectFile

.export keyFileReturn
keyFileReturn:
  jsr selectSlot

  ldx selectedSlot
  cpx #BOOT_SLOT
  beq :+
    ldx #BOOT_SLOT
    jsr markEraseBlock
:

  ; set slotPtr to slot description
  ldx selectedSlot
  
  ; get slot type
  lda slotDescrType,x
  sta oldType

  ; check if erased
  cmp #$ff
  beq :+
    ; mark slot to be erased
    jsr eraseSlot

    ; set slotPtr to slot description
    ldx selectedSlot

  ; mark slot to be programmed
:
  lda action,x
  and #ACTION_ERASE
  ora #ACTION_PROGRAM
  sta action,x

  ; set slot ptr to slot name
  jsr setSlotPtrName

  ; set slot type to kernal
  lda oldType
  cmp #$40
  bcc :+
    cmp #$ff
    bne :++
:
  lda #$41
:
  sta slotDescrType,x


  ; set srcPtr to filename
  ldx selectedFile
  jsr setSrcPtrFile

  ; set len to filename length 
  ldy #18
  lda (srcPtr),y
  sta len

  ; copy filename into slot description
  ldy #0
:
  lda (srcPtr),y
  tax
  lda _pet2screen,x
  sta (slotPtr),y
  iny
  cpy #16
  beq :++
  cpy len
  bne :-

  ; fill up filename in slot description with spaces
  lda #$20
:
  sta (slotPtr),y
  iny
  cpy #16
  bne :-
:
  ; remember drive
  ldx selectedSlot
  lda selectedDrive
  sta fnDrive,x
 
  ; remember filename for slot
  jsr setSlotPtrFn
  ldy #0
:
  lda (srcPtr),y
  sta (slotPtr),y
  iny
  cpy len
  bne :-

  ; store length of filename
  lda len
  sta fnLenSlot,x

  ; load file
  jsr loadSlot

  jsr selectSlot

  jmp selectType


  





.export drawFile
drawFile:


  ldx screenItem
  lda fileScreenLo,x
  sta screenPtr
  lda fileScreenHi,x
  sta screenPtr+1

  ldx drawItem

  jsr setSrcPtrFile

  ldy #18
  lda (srcPtr),y
  sta len

  ldy #0
:
  lda (srcPtr),y
  tax
  lda _pet2screen,x
  eor inverse
  sta (screenPtr),y
  iny
  cpy len
  bne :-

  cpy #22
  beq :++

  lda #$20
  eor inverse
:
  sta (screenPtr),y
  iny
  cpy #23
  bne :-
:

  rts

.export drawFileSpace
drawFileSpace:
  ldx screenItem
  lda fileScreenLo,x
  sta screenPtr
  lda fileScreenHi,x
  sta screenPtr+1
  ldy #22
  lda #$20
:
  sta (screenPtr),y
  dey
  bpl :-
  rts
  

.export loadSlot
loadSlot:
  lda #0
  sta crc

  stx slot
  stx slotTmp
  jsr printStatusFrame
  ldx slot
  jsr printStatusLoadSlot
  ldx slot


  ; set size to 0
  lda #0
  sta size
  sta size+1

  ; load
  jsr setSlotPtrFn
  lda fnLenSlot,x
  ldx slotPtr
  ldy slotPtr+1
  jsr KERNAL_SETNAM

  ldx slot
  lda fnDrive,x
  tax
  lda #2
  ldy #2
  jsr KERNAL_SETLFS

  jsr KERNAL_OPEN
  bcc :+
    jmp loadSlotFileError
:

  ldx #2
  jsr KERNAL_CHKIN

  ldx slot
  jsr newMemSlot

  ldy #0
  ldx #$20
  stx len
loadSlotLoop:
    jsr KERNAL_READST
    bne loadSlotEof
loadSlotNext:
    jsr KERNAL_CHRIN
    sta (slotPtr),y

    crc8 crc
     
    inc size
    iny
    bne loadSlotLoop

    inc size+1
    inc slotPtr+1
    dec len
    bne loadSlotLoop

    jsr KERNAL_READST
    bne loadSlotEof

    sei

    ;store crc
    ldx slotTmp
    lda crc
    sta slotDescrCrc,x
    lda #0
    sta crc

    ; find next free slot as follow up slot
:
    inx
    cpx #$40
    bne :+
      jmp loadSlotOutOfSpace
:

    lda slotDescrType,x
    cmp #$ff
    bne :--

    stx slotTmp

    ; set program action
    lda action,x
    ora #ACTION_PROGRAM
    sta action,x

    ; set slot type to start slot number
    lda slot
    sta slotDescrType,x

    ; copy slot name
    ldy slot
    jsr setSrcSlotPtrName
    ldy #15
:
      lda (srcPtr),y
      sta (slotPtr),y
      dey
      bpl :-

    ; print loading slot number
    jsr printStatusLoadSlot

    ; allocate new memory slot
    ldx slotTmp
    jsr newMemSlot

    ldx #$20
    stx len
    ldy #0
    jmp loadSlotNext

.export loadSlotEof
loadSlotEof:
  and #$bf
  bne loadSlotFileError

  lda #2
  jsr KERNAL_CLOSE

  jsr KERNAL_CLRCHN

  sei

  lda len
  beq :++
  ldy size
:
  lda #$ff
  sta (slotPtr),y
  crc8 crc
  iny
  bne :-
  inc slotPtr+1
  dec len
  bne :-
:
  lda crc
  ldx slotTmp
  sta slotDescrCrc,x

  ; set slot size
  ldx slot
  lda size
  sta slotDescrSizeLo,x
  lda size+1
  sta slotDescrSizeHi,x

  ; set slot size for follow slots
:
  inx
  cpx #$40
  beq :+

    lda slotDescrType,x
    cmp slot
    bne :-

    lda size
    sta slotDescrSizeLo,x
    lda size+1
    sec
    sbc #$20
    sta size+1
    sta slotDescrSizeHi,x
    jmp :-
:
  rts
loadSlotOutOfSpace:
  jsr printStatusNotEnoughFree
  jmp :+
loadSlotFileError:
  jsr printStatusLoadingError
:

  ldx slot
  jmp resetFirst
resetLoop:
    lda slot
    cmp slotDescrType,x
    bne resetNext
resetFirst:
      jsr freeMemSlot

      lda #$ff
      sta slotDescrType,x

      lda action,x
      and #ACTION_ERASE
      sta action,x

      jsr setSlotPtrName

      ldy #15
      lda #$ff
:
      sta (slotPtr),y
      dey
      bpl :-

resetNext:
    inx
    cpx #$40
    bne resetLoop
  

  lda #2
  jsr KERNAL_CLOSE

  jsr KERNAL_CLRCHN
  sei
  rts

.export setSrcPtrFile
setSrcPtrFile:
  lda #0
  sta srcPtr+1
  txa

  asl a
  rol srcPtr+1
  asl a
  rol srcPtr+1
  asl a
  rol srcPtr+1
  asl a
  rol srcPtr+1
  asl a
  rol srcPtr+1
  clc
  adc dirPtr
  sta srcPtr
  lda dirPtr+1
  adc srcPtr+1
  sta srcPtr+1
  rts

dirName:
  .byte '$'
