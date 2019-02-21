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

.import         initlib, donelib
.import         zerobss
.import         callmain
.import         __STACK_START__                   ; Linker generated
.import         __STACK_SIZE__                   ; Linker generated
.import         __DATA_SIZE__                   ; Linker generated
.import         __DATA_RUN__                   ; Linker generated
.import         __DATA_LOAD__                   ; Linker generated
.importzp       ST

.include        "zeropage.inc"
.include        "c64.inc"

.segment "ROMPTR"
.word nmi, __STARTUP__, irq

.segment "CODE"
nmi:
        rti
irq:
        rti

.segment        "STARTUP"
.export __STARTUP__
__STARTUP__:
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
; Switch to the second charset.

; Clear the BSS data.

        jsr     zerobss

; Save some system settings; and, set up the stack.

        tsx
        stx     spsave          ; Save the system stack ptr

        lda     #<(__STACK_START__ + __STACK_SIZE__)
        sta     sp
        lda     #>(__STACK_START__ + __STACK_SIZE__)
        sta     sp+1            ; Set argument stack ptr

; Call the module constructors.

        jsr     initlib

; Push the command-line arguments; and, call main().

        jsr     callmain

; Back from main() [this is also the exit() entry]. Run the module destructors.
_exit:
        jsr     donelib

        ldx     spsave
        txs                     ; Restore stack pointer

        jmp __STARTUP__

; ------------------------------------------------------------------------
; Data

.bss

spsave:.res    1


