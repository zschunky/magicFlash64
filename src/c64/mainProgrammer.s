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
.include "slot.inc"
.include "backupSelect.inc"
.include "selectSlot.inc"


.segment "LOADADDR"
.export __LOADADDR__
__LOADADDR__:
.lobytes $0801
.hibytes $0801

.segment "EXEHDR"
.byte $0B, $08, $F0, $02, $9E, $32, $30, $36, $31, $00, $00, $00


.segment "STARTUP"
.export __STARTUP__
__STARTUP__:
  sei

  lda #$7
  sta $01
  sta $00

  ; set lowercase char
  lda #$17
  sta VIC_VIDEO_ADR

  ; set background color
  lda #COLOR_BACKGROUND
  sta VIC_BORDERCOLOR
  sta VIC_BG_COLOR0

  ; disable interrupts/nmi from vic/cia
  lda #$9f
  sta CIA2_ICR
  sta CIA1_ICR
  lda #00
  sta VIC_IMR



  jsr slotInit
  bcs error

  lda #1
  jsr selectSlot
  jsr checkSlots
  jsr selectSlot
  jsr backupSelect
  jsr _initKeys
:
  jsr _evalKey

  jmp :-
error:
  inc $d020
  jmp error
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

  
