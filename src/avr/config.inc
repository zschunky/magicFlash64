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

#include <avr/io.h>
#ifdef _SFR_IO8
#undef _SFR_IO8 
#endif
#define _SFR_IO8(i) i

#define _x r26
#define _y R28
#define _z r30

#define OE_PORT PORTB
#define OE_PIN PINB
#define OE_P   PB3
#define ADDR_PIN PINC
#define ADDR_MASK 0x3f
#define CMD_MASK 0x3e
#define LED_DDR DDRB
#define LED_P PB1
#define LED_PORT PORTB
#define RESET_PIN PINB
#define RESET_DDR DDRB
#define RESET_PORT PORTB
#define RESET_P PB2
#define RESET_INT PCINT2
#define RESET_INTMSK PCMSK0
#define RESET_IE PCIE0
#define RESET_VECT PCINT0_vect
#define SEL13OLD_DDR DDRC
#define SEL13OLD_P PC6
#define SEL13NEW_DDR DDRB
#define SEL13NEW_P PB5
#define SEL14_DDR DDRD
#define SEL14_P PD3
#define SEL15_DDR DDRD
#define SEL15_P PD4
#define SEL16_DDR DDRD
#define SEL16_P PD5
#define SEL17_DDR DDRD
#define SEL17_P PD6
#define SEL18_DDR DDRD
#define SEL18_P PD7
#define SEL14_18_MASK 0xf8
#define RW_PORT PORTB
#define RW_PIN PINB
#define RW_P PB0
#define WE_DDR DDRB
#define WE_PORT PORTB
#define WE_P PB4
#define RESTORE_PIN PIND
#define RESTORE_PORT PORTD
#define RESTORE_P PD2
#define RESTORE_DDR DDRD
;#define NMI_PIN  PINB
;#define NMI_P    PB5
;#define NMI_DDR  DDRB
#define NMI_PIN  RESTORE_PIN
#define NMI_PORT RESTORE_PORT
#define NMI_P    RESTORE_P
#define NMI_DDR  RESTORE_DDR

#define rTmp r16
#define rCmd xl
#define rLookup r17
#define rTmp2 r18
#define rSelect r19
#define rSel1418Mask r20
#define rTmp3 r21
#define rLoop r22
#define rLed r23
#define rTmp4 r24
#define rTmp5 r25
#define rPrev r15
#define rRestoreSelect r14
#define rSel13Old r13

#define zl r30
#define zh r31
; x reserved for cmd ptr
#define xl r26 
#define xh r27 
#define yl r28
#define yh r29

#define LED_FULL_CNT 39062
#define LED_HALF_CNT (LED_FULL_CNT/2)

.macro waitOe
  ; loop while OE is low
1:
  sbis OE_PIN,OE_P
  rjmp 1b
  ; loop while OE is high and ignore glitches
1:
  sbic OE_PIN,OE_P
  rjmp 1b
  ;nop
  ;sbic OE_PIN,OE_P
  ;rjmp 1b
.endm

.macro waitWr
  ; loop while RW is low
1:
  sbis RW_PIN,RW_P
  rjmp 1b
  ; loop while RW is high and ignore glitches
1:
  sbic RW_PIN,RW_P
  rjmp 1b
  ;nop
  ;sbic RW_PIN,RW_P
  ;rjmp 1b
;  nop
;  nop
.endm

.global cmdLed
.global cmdReset
.global cmdSelect
.global cmdWrModeAutoSelect
.global cmdWrModeProgram
.global cmdWrModeErase
.global cmdFwUpd
.global cmdSetDefault
.global cmdGetDefault
.global cmdGetSelected
.global cmdSetEeprom
.global cmdGetEeprom
.global cmdWrModeReset
.global cmdTest
.global cmdGetPrev
.global cmdSetRam
.global cmdGetRam
.global cmdGetVersion
.global cmdMcType
.global cmdSelectAfterInt
.global cmdSelectPrev
.global cmdSelectAfterRestoreInt
.global cmdNop
.global lookup
.global lookupLedFull
.global lookupLedHalf
.global ram
.global eeUserData
.global eeDefaultSlot
.global mainLoop
.global setLed
.global setSelect
.global writeEeprom
.global readEeprom
.global sendByte
.global mainBegin
.global reset
