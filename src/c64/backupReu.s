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


.export REU_STATUS
REU_STATUS   = $DF00
.export REU_COMMAND
REU_COMMAND  = $DF01
.export REU_C64BASE
REU_C64BASE  = $DF02
.export REU_REUBASE
REU_REUBASE  = $DF04
.export REU_TRANSLEN
REU_TRANSLEN = $DF07
.export REU_IRQMASK
REU_IRQMASK  = $DF09
.export REU_CONTROL
REU_CONTROL  = $DF0A



.data
.export memSlotReu
memSlotReu:
  .byte $ff
numReuSlots:
  .byte 64


.code

.export freeMemSlotReu
freeMemSlotReu:
  cpx memSlotReu
  bne :+
    lda #$ff
    sta memSlotReu
    rts
:
  txa
  ldx #0
:
    cmp bufferSlot,x
    beq freeMemSlotReuFound
    inx
    cpx numReuSlots
    bne :-
  rts
freeMemSlotReuFound:
  lda #$ff
  sta bufferSlot,x
  rts

.export popMemSlotReu
popMemSlotReu:
  cpx memSlotReu
  bne :+
    lda #$ff
    sta memSlotReu

    lda #<__TMP_RAM_START__
    sta srcPtr
    lda #>__TMP_RAM_START__
    sta srcPtr+1

    rts
:

  ldx memSlotReu
  cpx #$ff
  beq :+
    ldx memSlotReu
    jsr reuAllocSlot
    lda #$90
    sta REU_COMMAND
    lda #$ff
    sta memSlotReu
    
:
  lda slot
  ldx #0
:
    cmp bufferSlot,x
    beq popMemSlotReuFound
    inx
    cpx numReuSlots
    bne :-

  tax
  jmp reloadSlot

.export popMemSlotReuFound
popMemSlotReuFound:
  lda #$ff
  sta bufferSlot,x
  jsr setupReu

  lda #$91
  sta REU_COMMAND

  lda #<__TMP_RAM_START__
  sta srcPtr
  lda #>__TMP_RAM_START__
  sta srcPtr+1

  rts

.export initMemSlotReu
initMemSlotReu:
  ldx #64
  stx numReuSlots
  dex
  jsr setupReuCheck
  lda #$90
  sta REU_COMMAND

  ldx #32
  stx numReuSlots
  dex
  jsr setupReuCheck
  lda #$90
  sta REU_COMMAND

  ldx #16
  stx numReuSlots
  dex
  jsr setupReuCheck
  lda #$90
  sta REU_COMMAND

  ldx #63
  jsr setupReuCheck
  lda #$91
  sta REU_COMMAND

  ldx numReuSlots
  dex
  lda #$ff
:
  sta bufferSlot,x
  dex
  bpl :-

  lda #0
  sta REU_IRQMASK
  sta REU_CONTROL
  rts



  
  

.export newMemSlotReu
newMemSlotReu:
  stx tmp6

  ; check if slot already exists
  txa
  ldx #0
:
  cmp bufferSlot,x
  bne :+
    lda #$ff
    sta bufferSlot,x
    jmp :++
:
  inx
  cpx numReuSlots
  bne :--
:
  ldx memSlotReu
  cpx #$ff
  beq :+
    jsr reuAllocSlot
    lda #$90
    sta REU_COMMAND
:
  lda tmp6
  sta memSlotReu


  lda #<__TMP_RAM_START__
  sta slotPtr
  lda #>__TMP_RAM_START__
  sta slotPtr+1

  rts

.export reuAllocSlot
reuAllocSlot:
  ; search for free slot
  lda #$ff
  ldy #0
:
    cmp bufferSlot,y
    beq reuAllocSlotFound

    iny
    cpy numReuSlots
    bne :-

  ; search for non backup slot
  stx tmp1
  ldy #0
:
    ldx bufferSlot,y
    lda action,x
    and #ACTION_REFLASH
    beq :++

    iny
    cpy numReuSlots
    bne :-
:
  inc VIC_BORDERCOLOR
  jmp :-
:
  ldx tmp1
  

reuAllocSlotFound:
  txa
  sta bufferSlot,y
  tya
  tax

.export setupReu
setupReu:
  lda #<__TMP_RAM_START__
  sta REU_C64BASE
  lda #>__TMP_RAM_START__
  sta REU_C64BASE+1

  lda #0
  sta REU_TRANSLEN
  lda #$20
  sta REU_TRANSLEN+1

setupReuReuBase:
  lda #0
  sta tmp1

  txa
  lsr a
  ror tmp1
  lsr a
  ror tmp1
  lsr a
  ror tmp1
  
  sta REU_REUBASE+2
  lda tmp1
  sta REU_REUBASE+1
  lda #0
  sta REU_REUBASE

  rts

.export setupReuCheck
setupReuCheck:
  lda #<numReuSlots
  sta REU_C64BASE
  lda #>numReuSlots
  sta REU_C64BASE+1

  lda #1
  sta REU_TRANSLEN
  lda #0
  sta REU_TRANSLEN+1

  jmp setupReuReuBase
