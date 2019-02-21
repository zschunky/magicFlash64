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
.include "magicFlash64Colors.inc"
.include "key.inc"
.include "screenNum.inc"
.include "num.inc"
.include "zeropage.inc"
.include "magicFlash64Lib.inc"
.include "screenCpy.inc"
.include "selectSlotMenu.inc"
.include "textMenuEn.inc"
.include "injectInt.inc"
.include "pla.inc"


.define VERSION_MAJOR 0
.define VERSION_MINOR 2

.import __DATA_LOAD__
.import __DATA_RUN__
.import __DATA_SIZE__
.import __DATA2_LOAD__
.import __DATA2_RUN__
.import __DATA2_SIZE__
.import __STACK_SIZE__

.segment "STARTUP"
.export reset
reset:
  sei

  ; set stack
  ldx #<(__STACK_SIZE__-1)
  txs

  ; set nmi jmp vector
  lda #<nmiFunc
  sta $0318
  lda #>nmiFunc
  sta $0319

  ; setup pla
  jsr plaInit

  ; copy data init
  lda #<__DATA_LOAD__
  sta tmp1
  lda #>__DATA_LOAD__
  sta tmp2
  lda #<__DATA_RUN__
  sta tmp3
  lda #>__DATA_RUN__
  sta tmp4
  ldy #0
  ldx #>__DATA_SIZE__
  beq dataInitShort
dataInitLongLoop:
  lda (tmp1),y
  sta (tmp3),y
  iny
  bne dataInitLongLoop
  inc tmp2
  inc tmp4
  dex
  bne dataInitLongLoop
dataInitShort:
  ldx #<__DATA_SIZE__
  beq dataInitDone
dataInitShortLoop:
  lda (tmp1),y
  sta (tmp3),y
  iny
  dex
  bne dataInitShortLoop
dataInitDone:

  ldx #0
:
    lda __DATA2_LOAD__,x
    sta __DATA2_RUN__,x
    inx
    cpx #<__DATA2_SIZE__
    bne :-

  ; setup screen
  lda #$1b
  sta VIC_CTRL1
  lda #$c8
  sta VIC_CTRL2
  lda #$17
  sta VIC_VIDEO_ADR
  lda #COLOR_BACKGROUND
  sta VIC_BORDERCOLOR
  sta VIC_BG_COLOR0
  lda #0
  sta VIC_SPR_ENA


  ; disable interrupts/nmi from vic/cia
  lda #$9f
  sta CIA2_ICR
  sta CIA1_ICR
  lda #00
  sta VIC_IMR



  jsr slotInit


  lda #<slotScreen
  ldx #>slotScreen
  jsr _screenCpy
  lda #<kernalTab
  ldx #>kernalTab
  jsr _screenCpy


  lda #<slotScreenMenuVerPtr
  sta screenPtr
  lda #>slotScreenMenuVerPtr
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
    
  lda #<slotScreenFwVerPtr
  sta screenPtr
  lda #>slotScreenFwVerPtr
  sta screenPtr+1

  ; get fw version number
  jsr _ekGetVersion
  cmp #$00
  bne :++
    cpx #$00
    bne :++
:
     inc $d020
     jmp :-
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

  lda cart
  bne :+
    lda #<cartNotDetected
    ldx #>cartNotDetected
    jmp :++
:
    lda #<cartDetected
    ldx #>cartDetected
:
  jsr _screenCpy
   

  jsr selectSlotMenu
:
  jsr _evalKey

  jmp :-
;  ; stop timer
;  lda #0
;  sta $dd0e
;  sta $dd0f
;  lda #<1000
;  sta $dd04
;  lda #>1000
;  sta $dd05
;  lda #<250
;  sta $dd06
;  lda #>250
;  sta $dd07
;
;  ; clr int and flags
;  lda #$7f
;  sta $dd0d
;
;  ; start timers
;  lda #$49
;  sta $dd0f
;  lda #$01
;  sta $dd0e
;:
;  lda $dd0d
;  and #2
;  beq :-
;
;  jmp :--

.code
.export irq
irq:
  pha
  txa
  pha
  tya
  pha

  tsx
  cpx #<__STACK_SIZE__
  bcc :+
    jmp injectInt
:
  pla
  tay
  pla
  tax
  pla

  rti
.export nmi
nmi:
  pha
  txa
  pha
  tya
  pha

  tsx
  cpx #<__STACK_SIZE__
  bcc :+
    jmp injectInt
:
  pla
  tay
  pla
  tax
  pla


  jmp ($0318)
nmiFunc:
  rti  

.segment "ROMPTR"
.word nmi, reset, irq 
