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
.include "crc.inc"
.include "status.inc"
.include "zeropage.inc"
.include "screenNum.inc"
.include "backup.inc"
.include "pla.inc"
.include "num.inc"
.include "textProgrammerEn.inc"
.include "backupSelect.inc"

;incBegin
.define ACTION_ERASE 1
.define ACTION_PROGRAM 2
.define ACTION_REFLASH 4

;incEnd

.zeropage


.bss
.align 16
.export action
action:
  .res 64
.export slotDescrStart
slotDescrStart:
.export slotDescrType
slotDescrType:
  .res 64
.export slotDescrCrc
slotDescrCrc:
  .res 64
.export slotDescrSizeLo
slotDescrSizeLo:
  .res 64
.export slotDescrSizeHi
slotDescrSizeHi:
  .res 64
.export slotDescrName
slotDescrName:
  .res 64 * 16
slotDescrEnd:

.export fnLenSlot
fnLenSlot:
  .res 64
.export fileNamesSlot
fileNamesSlot:
  .res 64*16
.export fnDrive
fnDrive:
  .res 64

.define VERSION_MAJOR 0
.define VERSION_MINOR 2


.code
.export slotInit
slotInit:
  lda #<slotScreenProgVer
  sta screenPtr
  lda #>slotScreenProgVer
  sta screenPtr+1

  lda #VERSION_MAJOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ldy #0
  lda #46
  sta (screenPtr),y
  inc screenPtr
  bne :+
    inc screenPtr+1
:

  lda #VERSION_MINOR
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0
    
  lda #<slotScreenFwVer
  sta screenPtr
  lda #>slotScreenFwVer
  sta screenPtr+1

  ; get fw version number
  jsr _ekGetVersion
  cmp #$00
  bne :+
    cpx #$00
    bne :+
      sec
      rts
:
  tay
  txa
  pha
  tya

  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ldy #0
  lda #46
  sta (screenPtr),y
  inc screenPtr
  bne :+
    inc screenPtr+1
:

  pla
  jsr num8toDec16
  clc
  jsr screenNum16
  jsr screenNum0

  ; get select kernal slot and remember it
  jsr _ekGetSelected
  sta activeKernalSlot

  jsr _ekGetDefault
  ;lda #$3f
  sta defaultSlot

  lda #BOOT_SLOT
  jsr _ekSelect
  ldx #0
:
  lda $e000,x
  sta slotDescrStart,x
  lda $e100,x
  sta slotDescrStart+$100,x
  lda $e200,x
  sta slotDescrStart+$200,x
  lda $e300,x
  sta slotDescrStart+$300,x
  lda $e400,x
  sta slotDescrStart+$400,x
  inx
  bne :-

  jsr initMemSlot

  lda #0
  ldx #63
:
  sta action,x
  dex
  bpl :-

  ; activate active kernal
  lda activeKernalSlot
  jsr _ekSelect

  lda #0
  sta selectedSlot
;  lda #$80
;  sta slotType

  ; disable basic
  jsr plaKernalIoOn

  clc
  rts


.export eraseSlot
eraseSlot:
  lda slotDescrType,x
  cmp #$ff
  beq :+
  cmp #$40
  bcs :+
    tax
:
  stx tmp1

  jsr freeMemSlot

  ldx tmp1
  jsr markEraseBlock
  ldx tmp1

  lda #ACTION_ERASE
  sta action,x


  lda #$ff
  sta slotDescrType,x
  sta slotDescrCrc,x

  jsr setSlotPtrName
  lda #$ff
  ldy #15
:
  sta (slotPtr),y
  dey
  bpl :-

:
  inx
  cpx #$40
  beq :++
    lda slotDescrType,x
    cmp tmp1
    bne :-


    stx tmp2
    jsr freeMemSlot
    ldx tmp2
    jsr markEraseBlock
    ldx tmp2
    
    lda #ACTION_ERASE
    sta action,x


    lda #$ff
    sta slotDescrType,x

    jsr setSlotPtrName
    lda #$ff
    ldy #15
:
    sta (slotPtr),y
    dey
    bpl :-

    jmp :--
    
:
  rts
.export setSrcSlotPtrName
setSrcSlotPtrName:
  lda slotDescrNameAddrLo,y
  sta srcPtr
  lda slotDescrNameAddrHi,y
  sta srcPtr+1
.export setSlotPtrName
setSlotPtrName:
  lda slotDescrNameAddrLo,x
  sta slotPtr
  lda slotDescrNameAddrHi,x
  sta slotPtr+1
  rts

.export markEraseBlock
markEraseBlock:
  lda #8
  sta len
  txa
  and #$38
  tax
:
  lda slotDescrType,x
  cmp #$ff
  beq :++

  lda action,x
  bne :+
  lda #(ACTION_REFLASH | ACTION_ERASE)
:
  ora #ACTION_ERASE
  .byte $2c
:
  lda #ACTION_ERASE
  sta action,x
  inx
  dec len
  bne :---
  rts

.export calcCrc
calcCrc:
  ldx #$00
  stx slotPtr
  lda #$e0
  sta slotPtr+1

  ldy #0
  sty crc
  sty tmp1

  lda slot
  cmp #$3f
  beq calcCrcMenu


.export calcCrcCont
calcCrcCont:
    jsr calcCrcData
    inc slotPtr+1
    bne calcCrcCont

    lda crc
    rts
.export calcCrcMenu
calcCrcMenu:
  
  lda #<(slotDescrCrc-slotDescrStart+BOOT_SLOT)
  sta tmp1
  jsr calcCrcData

  lda #$00
  crc8 crc

  iny
  lda #0
  sta tmp1
  jmp calcCrcCont

.export calcCrcData
calcCrcData:
:
  lda (slotPtr),y
  crc8 crc
  iny
  cpy tmp1
  bne :-
  rts

.export checkSlots
checkSlots:
  ; print status
  jsr printStatusFrame

  ; loop over all slots
  ldx #0
checkLoop:
    ; remember slot
    stx slot

    ; print status
    jsr printStatusCheckSlot
    
    ; activate slot
    lda slot
    jsr _ekSelect

    ; check slot type for erased or not
    ldx slot
    lda slotDescrType,x
    cmp #$ff
    beq checkErased
      ; calculate checksum on current slot
      jsr calcCrc

      ; compare checksum
      ldx slot
      cmp slotDescrCrc,x
      beq checkCont
        ; active active kernal (in case someone wants to reset)
        lda activeKernalSlot
        jsr _ekSelect
            
        ; print unexpected message
        ldx slot
        jsr printStatusUnexpCrc

        ; move on to next slot
        jmp checkCont

checkErased:
    ; set ptr to slot
    lda #$00
    sta slotPtr
    lda #$e0
    sta slotPtr+1

    ; loop over all bytes of slot
    ldy #0
    lda #$ff
checkErasedLoop:
      ; make sure it is erased (=$ff)
      cmp (slotPtr),y
      bne checkEraseUnexp

      ; move to next byte
      iny
      bne checkErasedLoop
      inc slotPtr+1
      bne checkErasedLoop
      jmp checkCont
checkEraseUnexp:
    ; activate active kernal
    lda activeKernalSlot
    jsr _ekSelect
        
    ; print unexpected message
    ldx slot
    jsr printStatusUnexpErase

checkCont:
    ; move to next slot
    ldx slot
    inx
    cpx #$40
    bne checkLoop

  ; activate active kernal
  lda activeKernalSlot
  jsr _ekSelect
  rts


.export setSlotPtrFn
setSlotPtrFn:
  lda #0
  sta slotPtr+1
  txa

  asl a
  rol slotPtr+1
  asl a
  rol slotPtr+1
  asl a
  rol slotPtr+1
  asl a
  rol slotPtr+1
  clc
  adc #<fileNamesSlot
  sta slotPtr
  lda #>fileNamesSlot
  adc slotPtr+1
  sta slotPtr+1
  rts



.export slotDigit0
slotDigit0:  
  .byte 48,48,48,48,48,48,48,48,48,48
  .byte 49,49,49,49,49,49,49,49,49,49
  .byte 50,50,50,50,50,50,50,50,50,50
  .byte 51,51,51,51,51,51,51,51,51,51
  .byte 52,52,52,52,52,52,52,52,52,52
  .byte 53,53,53,53,53,53,53,53,53,53
  .byte 54,54,54,54
.export slotDigit1
slotDigit1:  
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51,52,53,54,55,56,57
  .byte 48,49,50,51
slotDescrNameAddrLo:
  .repeat 64,i
    .lobytes slotDescrName+i*16
  .endrepeat
slotDescrNameAddrHi:
  .repeat 64,i
    .hibytes slotDescrName+i*16
  .endrepeat




