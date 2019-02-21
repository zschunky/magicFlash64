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

.define CIA2_PA_IEC_DATA_IN() (1<<7)
.define CIA2_PA_IEC_CLK_IN() (1<<6)
.define CIA2_PA_IEC_NDATA_OUT() (1<<5)
.define CIA2_PA_IEC_NCLK_OUT() (1<<4)
.define CIA2_PA_IEC_NATN_OUT() (1<<3)

.define CIA2_PA2() (1<<2)

.define CIA2_PA_VA15() (1<<1)
.define CIA2_PA_VA14() (1<<0)

.define CIA2_PA_DEFAULT() (CIA2_PA2 | CIA2_PA_VA15 | CIA2_PA_VA14)

.define IEC_LISTEN $20
.define IEC_UNLISTEN $3f
.define IEC_TALK $40
.define IEC_UNTALK $5f
.define IEC_DATA $60
.define IEC_CLOSE $e0
.define IEC_OPEN $f0

.define IEC_ST_TIMEOUT_DIR()        (1<<0)
.define IEC_ST_TIMEOUT()            (1<<1)
.define IEC_ST_VERIFY_ERR()         (1<<4)
.define IEC_ST_EOI()                (1<<6)
.define IEC_ST_DEVICE_NOT_PRESENT() (1<<7)

.zeropage
kernalAddress:
  .res 1
kernalSecondary:
  .res 1
kernalFnLen:
  .res 1
kernalFnPtr:
  .res 2
kernalSt:
  .res 1
kernalIec:
  .res 1
kernalPa:
  .res 1

.code

.macro waitData exp,timeout,waitDone
.scope
.ifnblank timeout
  ldx #timeout
wait:
  bit CIA2_PRA
  dex
  .if exp = 1
    bpl waitDone
  .else
    bmi waitDone
  .endif
  bne wait
.else
wait:
  bit CIA2_PRA

  .if exp = 1
    bmi wait
  .else
    bpl wait
  .endif
.endif
.endscope
.endmacro

.macro waitClk exp,timeout,waitDone
.scope
.ifnblank timeout
  ldx #timeout
wait:
  bit CIA2_PRA
  dex
  .if exp = 1
    bvs waitDone
  .else
    bvc waitDone
  .endif
  bne wait
.else
wait:
  bit CIA2_PRA

  .if exp = 1
    bvc wait
  .else
    bvs wait
  .endif
.endif
.endscope
.endmacro

.macro waitClkData expClk,expData,timeout,clkWaitDone,dataWaitDone
.scope
  ldx #timeout
wait:
  bit CIA2_PRA
  .if expClk = 1
    bvs clkWaitDone
  .else
    bvc clkWaitDone
  .endif
  .if expData = 1
    bmi dataWaitDone
  .else
    bpl dataWaitDone
  .endif
  dex
  bne wait
.endscope
.endmacro

sendIec:
  sta kernalIec


  ; set clk low
  lda kernalPa
  ora #CIA2_PA_IEC_NCLK_OUT
  sta CIA2_PRA

  ; wait till data got pulled low
  waitData 0,105,:+

  ; mark device as not present
  lda #IEC_ST_DEVICE_NOT_PRESENT
  sta kernalSt

  ; release clk
  lda kernalPa
  sta CIA2_PRA

  sec
  rts
:

  ; issue ready to send clk will be pulled up
  lda kernalPa
  sta CIA2_PRA

  ; wait till data goes high
  ; TODO: add timeout
  waitData 1

  ; check for eoi
  bit kernalSt
  bvc :+++
    ; wait for timeout on listerner (data low)
    waitData 0

    ; and data high again
    waitData 1
    
:

  ; wait ~40us
  ldx #8
:
    dex
    bne :-

  ; loop over all bits
  ldx #8
sendIecBitLoop:
    
    lsr kernalIec
    bcs :+

      lda kernalPa
      ora #CIA2_PA_IEC_NCLK_OUT | CIA2_PA_IEC_NDATA_OUT
      sta CIA2_PRA
      jmp sendIecBitCont
:
      lda kernalPa
      ora #CIA2_PA_IEC_NCLK_OUT
      sta CIA2_PRA
      
      nop
sendIecBitCont:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    eor #CIA2_PA_IEC_NCLK_OUT 
    sta CIA2_PRA

    nop
    nop
    nop
    nop
    dex
    bne sendIecBitLoop

  nop
  nop
  nop
  nop
  ; clk low
  lda kernalPa
  ora #CIA2_PA_IEC_NCLK_OUT
  sta CIA2_PRA

  ; wait till data is accepted
  waitData 0,105,:+
  
  lda #IEC_ST_TIMEOUT
  sta kernalSt

  sec
  rts
:
  clc

  rts

activateAtn:
  ldx #CIA2_PA_DEFAULT|CIA2_PA_IEC_NATN_OUT
  stx kernalPa
  stx CIA2_PRA
  rts

deactivateAtn:
  ldx #CIA2_PA_DEFAULT
  stx kernalPa
  stx CIA2_PRA
  rts

recvIecInit:
  ; clk will be pulled up, data low
  lda kernalPa
  ora #CIA2_PA_IEC_NDATA_OUT
  sta CIA2_PRA

  ; wait for clk go low
:
  bit CIA2_PRA
  bvs :-

  rts

recvIecError:
  lda #IEC_ST_TIMEOUT
  sta kernalSt

  sec
  rts
  
  
recvIec:
  ; wait for clk go high
  waitClk 1

  ; data will be pulled up (ready to receive)
  lda kernalPa
  sta CIA2_PRA

  ; wait for clk go low
  waitClkData 0,0,105,recvIecCont, recvIecError

    ; pull data low
    lda kernalPa
    ora #CIA2_PA_IEC_NDATA_OUT
    sta CIA2_PRA

    ; mark eoi
    lda #IEC_ST_EOI
    sta kernalSt

    ; wait ~60us
    ldx #12
:
      dex
      bne :-

    ; data will be pulled up (ready to receive)
    lda kernalPa
    sta CIA2_PRA

    ; wait for clk go low
    waitClk 0


    

recvIecCont:
  ; loop over all 8 bits
  ldx #8
recvIecBitLoop:
    ; wait for clk go high
:
    lda CIA2_PRA
    asl
    bpl :-

    ; shift data in
    ror kernalIec

    ; wait for clk go low
    waitClk 0

    dex
    bne recvIecBitLoop

  ; pull data low
  lda kernalPa
  ora #CIA2_PA_IEC_NDATA_OUT
  sta CIA2_PRA

  lda kernalIec
  clc
  rts

kernalIoinit:
  jmp ($fffc)
  ; set ATN-OUT, CLK-OUT and DATA-OUT to output
  lda #CIA2_PA_IEC_NDATA_OUT | CIA2_PA_IEC_NCLK_OUT | CIA2_PA_IEC_NATN_OUT | CIA2_PA2 | CIA2_PA_VA15 | CIA2_PA_VA14
  sta CIA2_DDRA
  lda #CIA2_PA_DEFAULT
  sta CIA2_PRA
  sta kernalPa
  rts

kernalReadst:
  lda kernalSt
  rts

kernalSetlfs:
  stx kernalAddress
  sty kernalSecondary
  rts

kernalSetnam:
  sta kernalFnLen
  stx kernalFnPtr
  sty kernalFnPtr+1
  rts

kernalOpen:
  ; reset st
  lda #0
  sta kernalSt

  ; activate atn
  jsr activateAtn

  ; send listen to device
  lda kernalAddress
  ora #IEC_LISTEN
  jsr sendIec
  bcs kernalOpenExit

  ; send open with secondary address
  lda kernalSecondary
  ora #IEC_OPEN
  jsr sendIec
  bcs kernalOpenExit

  ; deactivate atn
  jsr deactivateAtn

  ; send fn
  ldy #0
:
    lda (kernalFnPtr),y
    iny
    cpy kernalFnLen
    bne :+
      lda #IEC_ST_EOI
      sta kernalSt
:
    jsr sendIec
    bcs kernalOpenExit
    cpy kernalFnLen
    bne :--

  ; activate atn
  jsr activateAtn

  ; send unlisten
  lda #IEC_UNLISTEN
  jsr sendIec

kernalOpenExit:
  ; deactivate atn
  jsr deactivateAtn

  rts

kernalClose:
  ; reset st
  lda #0
  sta kernalSt

  ; activate atn
  jsr activateAtn

  ; send listen to device
  lda kernalAddress
  ora #IEC_LISTEN
  jsr sendIec
  bcs kernalCloseExit

  ; send close with secondary address
  lda kernalSecondary
  ora #IEC_CLOSE
  jsr sendIec
  bcs kernalCloseExit

  ; send unlisten
  lda #IEC_UNLISTEN
  jsr sendIec

kernalCloseExit:
  ; deactivate atn
  jsr deactivateAtn

  rts

kernalChkin:
  ; reset st
  lda #0
  sta kernalSt

  ; activate atn
  jsr activateAtn

  ; send talk to device
  lda kernalAddress
  ora #IEC_TALK
  jsr sendIec
  bcs kernalCloseExit

  ; send data with secondary address
  lda kernalSecondary
  ora #IEC_DATA
  jsr sendIec
  bcs kernalCloseExit

  ; deactivate atn
  jsr deactivateAtn

  ; switch to recv
  jsr recvIecInit
  
  rts
kernalChkout:
kernalChrin:
  jsr recvIec
  rts
kernalChrout:
kernalLoad:
kernalSave:

kernalClrchn:
kernalUntlk:
kernalUnlsn:
kernalListen:
kernalTalk:
kernalCint:
kernalRamtas:
kernalRestor:
kernalVector:
kernalSetmsg:
kernalSecond:
kernalTksa:
kernalMemtop:
kernalMembot:
kernalScnkey:
kernalSettmo:
kernalAcptr:
kernalCiout:
kernalSettim:
kernalRdtim:
kernalStop:
kernalGetin:
kernalClall:
kernalUdtim:
kernalScreen:
kernalPlot:
kernalIobase:
  rts


.segment "ROMVECTORS"
  jmp kernalCint	
  jmp kernalIoinit
  jmp kernalRamtas
  jmp kernalRestor
  jmp kernalVector
  jmp kernalSetmsg
  jmp kernalSecond
  jmp kernalTksa
  jmp kernalMemtop
  jmp kernalMembot
  jmp kernalScnkey
  jmp kernalSettmo
  jmp kernalAcptr
  jmp kernalCiout
  jmp kernalUntlk
  jmp kernalUnlsn
  jmp kernalListen
  jmp kernalTalk
  jmp kernalReadst
  jmp kernalSetlfs
  jmp kernalSetnam
  jmp kernalOpen
  jmp kernalClose
  jmp kernalChkin
  jmp kernalChkout
  jmp kernalClrchn
  jmp kernalChrin
  jmp kernalChrout
  jmp kernalLoad
  jmp kernalSave
  jmp kernalSettim
  jmp kernalRdtim
  jmp kernalStop
  jmp kernalGetin
  jmp kernalClall
  jmp kernalUdtim
  jmp kernalScreen
  jmp kernalPlot
  jmp kernalIobase

