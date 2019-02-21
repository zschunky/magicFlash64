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
.include "breakPoint.inc"

.import __TMP_RAM_START__


GEORAM_MEM=$DE00
GEORAM_BLOCK=$DFFF
GEORAM_PAGE=$DFFE


.data
.export memSlotGeoRam
memSlotGeoRam:
  .byte $ff

.code

.export freeMemSlotGeoRam
freeMemSlotGeoRam:
  cpx memSlotGeoRam
  bne :+
    lda #$ff
    sta memSlotGeoRam
    rts
:
  txa
  ldx #0
:
    cmp bufferSlot,x
    beq freeMemSlotGeoRamFound
    inx
    cpx #64
    bne :-
  rts
freeMemSlotGeoRamFound:
  lda #$ff
  sta bufferSlot,x
  rts

.export popMemSlotGeoRam
popMemSlotGeoRam:
  cpx memSlotGeoRam
  bne :+
    lda #$ff
    sta memSlotGeoRam

    lda #<__TMP_RAM_START__
    sta srcPtr
    lda #>__TMP_RAM_START__
    sta srcPtr+1

    rts
:

  ldx memSlotGeoRam
  cpx #$ff
  beq :+
    jsr geoRamAllocSlot
    jsr copyToGeoRam
    lda #$ff
    sta memSlotGeoRam
    
:
  lda slot
  ldx #0
:
    cmp bufferSlot,x
    beq popMemSlotGeoRamFound
    inx
    cpx #64
    bne :-

  tax
  jmp reloadSlot

.export popMemSlotGeoRamFound
popMemSlotGeoRamFound:
  lda #$ff
  sta bufferSlot,x
  jsr setupGeoRam
  jsr copyFromGeoRam

  lda #<__TMP_RAM_START__
  sta srcPtr
  lda #>__TMP_RAM_START__
  sta srcPtr+1

  rts

.export initMemSlotGeoRam
initMemSlotGeoRam:
  ldx #$3f
  lda #$ff
  sta memSlotGeoRam

:
  sta bufferSlot,x
  dex
  bpl :-
  rts



  
  

.export newMemSlotGeoRam
newMemSlotGeoRam:
  cpx #$ff
  beq :++
  cpx #$40
  bcc :++

  stx $0400
:
  inc $d020
  jmp :-



:
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
    cpx #64
    bne :--
:
  ldx memSlotGeoRam
  cpx tmp6
  beq :+
  cpx #$ff
  beq :+
    jsr geoRamAllocSlot
    jsr copyToGeoRam
:
  lda tmp6
  sta memSlotGeoRam


  lda #<__TMP_RAM_START__
  sta slotPtr
  lda #>__TMP_RAM_START__
  sta slotPtr+1

  rts

.export geoRamAllocSlot
geoRamAllocSlot:
  ; search for free slot
  lda #$ff
  ldy #0
:
    cmp bufferSlot,y
    beq geoRamAllocSlotFound

    iny
    cpy #64
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
    cpy #64
    bne :-
:
  inc VIC_BORDERCOLOR
  jmp :-
:
  ldx tmp1
  

geoRamAllocSlotFound:
  txa
  sta bufferSlot,y
  tya
  tax

.export setupGeoRam
setupGeoRam:
  txa
  ldx #0
  lsr a
  bcc :+
    ldx #$20
:
  
  sta GEORAM_BLOCK
  stx tmp1

  rts

.export copyToGeoRam
copyToGeoRam:
  lda #<__TMP_RAM_START__
  sta tmp2
  lda #>__TMP_RAM_START__
  sta tmp3

  ldx #$20
  ldy #0
:
  lda tmp1
  sta GEORAM_PAGE
:
  lda (tmp2),y
  sta GEORAM_MEM,y
  iny
  bne :-
  inc tmp3
  inc tmp1
  dex
  bne :--

  ;jsr breakPoint
  rts

.export copyFromGeoRam
copyFromGeoRam:
  lda #<__TMP_RAM_START__
  sta tmp2
  lda #>__TMP_RAM_START__
  sta tmp3

  ldx #$20
  ldy #0
:
  lda tmp1
  sta GEORAM_PAGE
:
  lda GEORAM_MEM,y
  sta (tmp2),y
  iny
  bne :-
  inc tmp3
  inc tmp1
  dex
  bne :--
  ;jsr breakPoint
  rts

