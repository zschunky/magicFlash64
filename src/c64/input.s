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

.include "zeropage.inc"
.include "tick.inc"
.include "key.inc"
.include "assembler.inc"
.macpack cbm


.define cursorPos tmp8
.define cursorCnt tmp7
.define cursorDownCnt tmp6
.define keyChar tmp5
.define inputTmp tmp3

.code
.export input
input:
  ldy #0
:
    lda (srcPtr),y
    sta (screenPtr),y
    iny
    cpy len
    bne :-

  lda #<keyTableInput
  sta keyJmpTableKey
  lda #>keyTableInput
  sta keyJmpTableKey+1
  lda #<keyTableInputLo
  sta keyJmpTableLo
  lda #>keyTableInputLo
  sta keyJmpTableLo+1
  lda #<keyTableInputHi
  sta keyJmpTableHi
  lda #>keyTableInputHi
  sta keyJmpTableHi+1

  lda #<inputTick
  sta tickPtr
  lda #>inputTick
  sta tickPtr+1

  lda #0
  sta cursorCnt
  sta cursorPos

  lda #$ff
  sta cursorDownCnt
  rts

.export inputTick
inputTick:
  ldy cursorPos

  inc cursorCnt
  lda cursorCnt

  cmp #25
  bne :+
    lda (screenPtr),y
    and #$7f
    sta (screenPtr),y
    jmp :+
:
  cmp #50
  bne :+
    lda #0
    sta cursorCnt

    lda (screenPtr),y
    ora #$80
    sta (screenPtr),y

:

  lda cursorDownCnt
  cmp #$ff
  beq :+
    dec cursorDownCnt
    bne :+
      lda #10
      sta cursorDownCnt
      bne keyInputLrEval


:
  rts

.export keyInputLr
keyInputLr:
  lda #25
  sta cursorDownCnt

keyInputLrEval:


  jsr isShiftKeyDown
  beq keyInputL
keyInputR:
    ldy cursorPos
    cpy len
    beq keyInputLrDone
  
    lda (screenPtr),y
    and #$7f
    sta (screenPtr),y
    iny
    jmp keyInputDone

keyInputL:
    ldy cursorPos
    beq keyInputLrDone
  
    lda (screenPtr),y
    and #$7f
    sta (screenPtr),y
    dey
     
keyInputDone:
  sty cursorPos

  lda #0
  sta cursorCnt

  lda (screenPtr),y
  ora #$80
  sta (screenPtr),y
keyInputLrDone:
  rts

.export keyInputLrRelease
keyInputLrRelease:
  lda #$ff
  sta cursorDownCnt
  rts

.export keyInputReturn
keyInputReturn:
  ldy #0
  sty tickPtr
  sty tickPtr+1
  ldx #0
:
    lda (screenPtr),y
    and #$7f
    cmp (srcPtr),y
    beq :+
      inx
      sta (srcPtr),y
:
    iny
    cpy len      
    bne :--

  cpx #0
  jmp (inputDonePtr)

.export keyInputStop
keyInputStop:
  ldx #0
  stx tickPtr
  stx tickPtr+1
  jmp (inputDonePtr)


.export keyInputDel
keyInputDel:
  jsr isShiftKeyDown
  beq :++
    ldy cursorPos
    beq keyInputDelDone

    lda (screenPtr),y
    and #$7f
    sta (screenPtr),y

    dey

:
      iny
      lda (screenPtr),y
      dey
      sta (screenPtr),y
      iny
      cpy len      
      bne :-
      
    ldy cursorPos
    dey
    jmp keyInputDone
:

  
  ldy len
  dey
  cpy cursorPos
  beq :++
  bcc :++

:
    dey
    lda (screenPtr),y
    and #$7f
    iny 
    sta (screenPtr),y
    dey
    cpy cursorPos
    bne :-
:
  ldy cursorPos

  lda #32
  sta (screenPtr),y
  jmp keyInputDone
      
keyInputDelDone:
  rts

.export keyInputHome
keyInputHome:
  jsr isShiftKeyDown
  beq :+
    
    ldy cursorPos
    beq keyInputLrDone
  
    lda (screenPtr),y
    and #$7f
    sta (screenPtr),y

    ldy #0
    jmp keyInputDone
:
  lda #32
  ldy len
:
   sta (screenPtr),y
   dey
   bpl :-

  ldy #0
  jmp keyInputDone

.export keyInputAll
keyInputAll:
  stx keyChar
  ldy cursorPos
  cpy len
  beq keyInputAllDone
    jsr isShiftKeyDown
    bne :+
      lda #<keyInputShiftLookup
      ldx #>keyInputShiftLookup
      bne keyInputAllCont
:
    ldax #KEY2MASK KEY_CBM
    jsr isKeyDown
    bne :+
      lda #<keyInputCbmLookup
      ldx #>keyInputCbmLookup
      bne keyInputAllCont
:
    lda #<keyInputLookup
    ldx #>keyInputLookup

keyInputAllCont:
    sta inputTmp
    stx inputTmp+1
    ldy keyChar
    lda (inputTmp),y
    cmp #$ff
    beq keyInputAllDone
      ldy cursorPos
      
      sta (screenPtr),y

      iny
      jmp keyInputDone

keyInputAllDone:
  rts


.export keyInputLookup
keyInputLookup:
  .byte $ff   ; KEY_DEL
  .byte $ff   ; KEY_RETURN
  .byte $ff   ; KEY_CRSR_LR
  .byte $ff   ; KEY_F7
  .byte $ff   ; KEY_F1
  .byte $ff   ; KEY_F3
  .byte $ff   ; KEY_F5
  .byte $ff   ; KEY_CRSR_UD
  scrcode "3" ; KEY_3
  scrcode "w" ; KEY_W
  scrcode "a" ; KEY_A
  scrcode "4" ; KEY_4
  scrcode "z" ; KEY_Z
  scrcode "s" ; KEY_S
  scrcode "e" ; KEY_E
  .byte $ff   ; KEY_SHIFT_L
  scrcode "5" ; KEY_5
  scrcode "r" ; KEY_R
  scrcode "d" ; KEY_D
  scrcode "6" ; KEY_6
  scrcode "c" ; KEY_C
  scrcode "f" ; KEY_F
  scrcode "t" ; KEY_T
  scrcode "x" ; KEY_X
  scrcode "7" ; KEY_7
  scrcode "y" ; KEY_Y
  scrcode "g" ; KEY_G
  scrcode "8" ; KEY_8
  scrcode "b" ; KEY_B
  scrcode "h" ; KEY_H
  scrcode "u" ; KEY_U
  scrcode "v" ; KEY_V
  scrcode "9" ; KEY_9
  scrcode "i" ; KEY_I
  scrcode "j" ; KEY_J
  scrcode "0" ; KEY_0
  scrcode "m" ; KEY_M
  scrcode "k" ; KEY_K
  scrcode "o" ; KEY_O
  scrcode "n" ; KEY_N
  scrcode "+" ; KEY_PLUS
  scrcode "p" ; KEY_P
  scrcode "l" ; KEY_L
  scrcode "-" ; KEY_MINUS
  scrcode "." ; KEY_DOT
  scrcode ":" ; KEY_COLON
  scrcode "@" ; KEY_AT
  scrcode "," ; KEY_COMMA
  .byte 28    ; KEY_POUND
  scrcode "*" ; KEY_ASTERIX
  scrcode ";" ; KEY_SEMICOLON
  .byte $ff   ; KEY_HOME
  .byte $ff   ; KEY_SHIFT_R
  scrcode "=" ; KEY_EQUAL
  .byte 30    ; KEY_PTR_U
  scrcode "/" ; KEY_SLASH
  scrcode "1" ; KEY_1
  .byte 31    ; KEY_PTR_L
  .byte $ff   ; KEY_CTRL
  scrcode "2" ; KEY_2
  scrcode " " ; KEY_SPACE
  .byte $ff   ; KEY_CBM
  scrcode "q" ; KEY_Q
  .byte $ff   ; KEY_STOP

.export keyInputShiftLookup
keyInputShiftLookup:
  .byte $ff   ; KEY_DEL
  .byte $ff   ; KEY_RETURN
  .byte $ff   ; KEY_CRSR_LR
  .byte $ff   ; KEY_F7
  .byte $ff   ; KEY_F1
  .byte $ff   ; KEY_F3
  .byte $ff   ; KEY_F5
  .byte $ff   ; KEY_CRSR_UD
  scrcode "#" ; KEY_3
  scrcode "W" ; KEY_W
  scrcode "A" ; KEY_A
  scrcode "$" ; KEY_4
  scrcode "Z" ; KEY_Z
  scrcode "S" ; KEY_S
  scrcode "E" ; KEY_E
  .byte $ff   ; KEY_SHIFT_L
  scrcode "%" ; KEY_5
  scrcode "R" ; KEY_R
  scrcode "D" ; KEY_D
  scrcode "&" ; KEY_6
  scrcode "C" ; KEY_C
  scrcode "F" ; KEY_F
  scrcode "T" ; KEY_T
  scrcode "X" ; KEY_X
  scrcode "'" ; KEY_7
  scrcode "Y" ; KEY_Y
  scrcode "G" ; KEY_G
  scrcode "(" ; KEY_8
  scrcode "B" ; KEY_B
  scrcode "H" ; KEY_H
  scrcode "U" ; KEY_U
  scrcode "V" ; KEY_V
  scrcode ")" ; KEY_9
  scrcode "I" ; KEY_I
  scrcode "J" ; KEY_J
  scrcode "0" ; KEY_0
  scrcode "M" ; KEY_M
  scrcode "K" ; KEY_K
  scrcode "O" ; KEY_O
  scrcode "N" ; KEY_N
  .byte 91    ; KEY_PLUS
  scrcode "P" ; KEY_P
  scrcode "L" ; KEY_L
  .byte 93    ; KEY_MINUS
  scrcode ">" ; KEY_DOT
  scrcode "[" ; KEY_COLON
  .byte 122   ; KEY_AT
  scrcode "<" ; KEY_COMMA
  .byte 105   ; KEY_POUND
  .byte 64    ; KEY_ASTERIX
  scrcode "]" ; KEY_SEMICOLON
  .byte $ff   ; KEY_HOME
  .byte $ff   ; KEY_SHIFT_R
  scrcode "=" ; KEY_EQUAL
  .byte 94    ; KEY_PTR_U
  scrcode "?" ; KEY_SLASH
  scrcode "!" ; KEY_1
  .byte 100   ; KEY_PTR_L
  .byte $ff   ; KEY_CTRL
  scrcode '"' ; KEY_2
  scrcode " " ; KEY_SPACE
  .byte $ff   ; KEY_CBM
  scrcode "Q" ; KEY_Q
  .byte $ff   ; KEY_STOP

.export keyInputCbmLookup
keyInputCbmLookup:
  .byte $ff   ; KEY_DEL
  .byte $ff   ; KEY_RETURN
  .byte $ff   ; KEY_CRSR_LR
  .byte $ff   ; KEY_F7
  .byte $ff   ; KEY_F1
  .byte $ff   ; KEY_F3
  .byte $ff   ; KEY_F5
  .byte $ff   ; KEY_CRSR_UD
  .byte $ff   ; KEY_3
  .byte 107   ; KEY_W
  .byte 112   ; KEY_A
  .byte $ff   ; KEY_4
  .byte 109   ; KEY_Z
  .byte 110   ; KEY_S
  .byte 113   ; KEY_E
  .byte $ff   ; KEY_SHIFT_L
  .byte $ff   ; KEY_5
  .byte 114   ; KEY_R
  .byte 108   ; KEY_D
  .byte $ff   ; KEY_6
  .byte 124   ; KEY_C
  .byte 123   ; KEY_F
  .byte 99    ; KEY_T
  .byte 125   ; KEY_X
  .byte $ff   ; KEY_7
  .byte 119   ; KEY_Y
  .byte $65   ; KEY_G
  .byte $ff   ; KEY_8
  .byte $7f   ; KEY_B
  .byte $74   ; KEY_H
  .byte $78   ; KEY_U
  .byte $7e   ; KEY_V
  scrcode ")" ; KEY_9
  .byte $62   ; KEY_I
  .byte $75   ; KEY_J
  scrcode "0" ; KEY_0
  .byte $67   ; KEY_M
  .byte $61   ; KEY_K
  .byte $79   ; KEY_O
  .byte $6a   ; KEY_N
  .byte $66   ; KEY_PLUS
  .byte $6f   ; KEY_P
  .byte $76   ; KEY_L
  .byte $5c   ; KEY_MINUS
  scrcode ">" ; KEY_DOT
  scrcode "[" ; KEY_COLON
  .byte $1b   ; KEY_AT
  scrcode "<" ; KEY_COMMA
  .byte $68   ; KEY_POUND
  .byte $5f   ; KEY_ASTERIX
  scrcode "]" ; KEY_SEMICOLON
  .byte $ff   ; KEY_HOME
  .byte $ff   ; KEY_SHIFT_R
  scrcode "=" ; KEY_EQUAL
  .byte $5e   ; KEY_PTR_U
  scrcode "?" ; KEY_SLASH
  .byte $ff   ; KEY_1
  .byte 31    ; KEY_PTR_L
  .byte $ff   ; KEY_CTRL
  .byte $ff   ; KEY_2
  scrcode " " ; KEY_SPACE
  .byte $ff   ; KEY_CBM
  .byte $6b   ; KEY_Q
  .byte $ff   ; KEY_STOP

 
.export keyTableInput
keyTableInput:
  .byte KEY_CRSR_LR, KEY_UP KEY_CRSR_LR , KEY_RETURN, KEY_DEL, KEY_HOME, KEY_STOP, KEY_ALL, $FF
  
.export keyTableInputLo
keyTableInputLo:
  .lobytes keyInputLr-1, keyInputLrRelease-1, keyInputReturn-1, keyInputDel-1, keyInputHome-1, keyInputStop-1, keyInputAll-1

.export keyTableInputHi
keyTableInputHi:
  .hibytes keyInputLr-1, keyInputLrRelease-1, keyInputReturn-1, keyInputDel-1, keyInputHome-1, keyInputStop-1, keyInputAll-1


.bss
.export inputDonePtr
inputDonePtr:
  .res 2
