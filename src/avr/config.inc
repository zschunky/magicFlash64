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

#define SYNC_PHI2 0x3c
#define PHI2_PORT PORTB
#define PHI2_DDR DDRB
#define PHI2_PIN PINB
#define PHI2_P   PB7
#ifdef M20
#define GPIO_PORT PORTB
#define GPIO_DDR DDRB
#define GPIO_PIN PINB
#define GPIO_P   PB5
#endif
#define OE_PORT PORTB
#define OE_PIN PINB
#define OE_P   PB3
#define ADDR_PIN PINC
#define ADDR_PORT PORTC
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

#define SCL_DDR DDRD
#define SCL_PIN PIND
#define SCL_P PD0
#define SCL_PORT PORTD
#define SDA_DDR DDRD
#define SDA_PIN PIND
#define SDA_P PD1

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
#ifdef M20
#define rSel13Old r13
#endif
#define rTmp6 r12
#define r00 r11
#define rFF   r10
#define rTmp7 r9
#define rTmp8 r8
#define rTmp9 r7
#define rTmp10 r6


#define zl r30
#define zh r31
; x reserved for cmd ptr
#define xl r26 
#define xh r27 
#define yl r28
#define yh r29

#define MC_TYPE_ATMEGA48_M20 4
#define MC_TYPE_ATMEGA48_DOT 104

#ifdef M20
#define MC_TYPE MC_TYPE_ATMEGA48_M20
#endif
#ifdef DOT
#define MC_TYPE MC_TYPE_ATMEGA48_DOT
#endif

.macro wait num
  .if \num >= 2
    rjmp 9f
9:
    wait "(\num - 2)"
  .endif
  .if \num == 1
    nop
  .endif

.endm
#ifdef M20
.macro waitOe reg=rTmp
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
  in \reg,ADDR_PIN
  andi \reg,ADDR_MASK
.endm

.macro waitWr reg
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
.ifnb \reg
  in \reg,ADDR_PIN
  andi \reg,ADDR_MASK
.endif
.endm

.macro dotWait num
.endm
#define SYNC
#define waitOeCheck waitOe
#define LED_FULL_CNT 39062
#endif

#ifdef DOT
.macro waitOeCheck reg=rTmp
  ldi rTmp,0
  ldi rTmp2,1<<SCL_P
  sbi SCL_DDR,SCL_P
  nop
  nop
  nop
  nop

1:
    out SCL_PORT,rTmp
    out SCL_PORT,rTmp2
    nop
    nop
    nop
    nop
    rjmp 1b
.endm
.macro waitOe reg=rTmp
1:
  in \reg,ADDR_PIN
  sbis OE_PIN,OE_P
    rjmp 1f
  wait 3
  rjmp 1b
1:
  ; 4 cycles left
.endm
.macro waitWr reg
1:
.ifnb \reg
  in \reg,ADDR_PIN
.else
  nop
.endif
  sbis RW_PIN,RW_P
    rjmp 1f
  wait 3
  rjmp 1b
1:
  ; 4 cycles left
.endm
.macro waitWrWe reg=rTmp
  cbi WE_PORT,WE_P
  nop
  nop
  nop
  nop
  nop
  nop

  waitWr \reg
  sbi WE_PORT,WE_P

  ; 2 cycles left
.endm
#define SYNC rcall sync
.macro dotWait num
  wait \num
.endm
#define LED_FULL_CNT 15625
#endif

#define LED_HALF_CNT (LED_FULL_CNT/2)
.macro setSelPrep

#ifdef M20
  sbrc rSel13Old,0
  rjmp 1f
#endif

  ; setup sel13
  in rTmp,SEL13NEW_DDR              ; 0+1
  andi rTmp,255^(1<<SEL13NEW_P)     ; 1+1
  sbrs rSelect,0                    ; 2+1
  ori rTmp,(1<<SEL13NEW_P)          ; 3+1

  mov rTmp2,rSelect                  ; 4+1

  ; set2p sel14-18
  lsl rTmp2                          ; 5+1
  lsl rTmp2                          ; 6+1
  and rTmp2,rSel1418Mask             ; 7+1
  eor rTmp2,rSel1418Mask             ; 0+1


#ifdef M20
  rjmp 2f
1:
  ; setup sel13
  in rTmp,SEL13OLD_DDR              
  andi rTmp,255^(1<<SEL13OLD_P)     
  sbrs rSelect,0                    
  ori rTmp,(1<<SEL13OLD_P)          

  mov rTmp2,rSelect                 

  ; set2p sel14-18
  lsl rTmp2                         
  lsl rTmp2                         
  and rTmp2,rSel1418Mask            
  eor rTmp2,rSel1418Mask            

2:
#endif
.endm

.macro setSelExec
#ifdef M20
  sbrs rSel13Old,0
#endif
  out SEL13NEW_DDR,rTmp             ; 0+1
#ifdef M20
  sbrc rSel13Old,0
  out SEL13OLD_DDR,rTmp             
#endif
  out SEL14_DDR,rTmp2               ; 1+1
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
.global cmdGetMode
.global cmdGetRecoveryVersion
.global getRecoveryVersion
.global cmdRecoveryUpdate
.global recovery
.global boot
.global cmdStall
.global sync
.global syncInit
.global syncImpl
.global syncInitImpl
.global waitInt
