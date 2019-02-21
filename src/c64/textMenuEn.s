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
.include "screenCpy.inc"
.macpack cbm

;incBegin
.define SELECT_LEN 22
;incEnd

.code
.export slotScreenMenuVerPtr
slotScreenMenuVerPtr=$0400 + 1 * 40 + 20
.export slotScreenFwVerPtr
slotScreenFwVerPtr=$0400 + 2 * 40 + 24
.export slotScreenSelectedKernalPtr
slotScreenSelectedKernalPtr=$0400 + 4 * 40 + 17
.export slotScreen
slotScreen:
  .lobytes $0400
  .hibytes $0400
  screenLine SC COLOR_BORDER,C_DR,SR 38,C_H,C_DL
  screenLine C_V,SC COLOR_TITLE,      "magicFlash64 menu v                 ",SC COLOR_HELP, "F1", SC COLOR_BORDER, C_V
  screenLine C_V,SC COLOR_FW,         "magicFlash64 firmware v           ", SC COLOR_HELP, "HELP", SC COLOR_BORDER, C_V

  .byte C_VR,SR 38,C_H,C_VL
  screenLine C_V,SC COLOR_MENU_KERNAL,"SELECTED KERNAL:                      ",SC COLOR_BORDER, C_V
  screenLine C_V,SC COLOR_MENU_CART,  "CART DETECTED:                        ",SC COLOR_BORDER, C_V
  .byte C_VR,SR 38,C_H,C_VL

  .byte C_V,SR 38,C_SP,C_V
  .byte C_V,SR 38,C_SP,C_V


  .byte C_V,SR 7,C_SP,C_DR,SR 22,C_H,C_DL,SR 7,C_SP,C_V
  .repeat 13
    .byte C_V,SR 7,C_SP,C_V,SR 22,C_SP,C_V,SR 7,C_SP,C_V
  .endrepeat
  .byte C_V,SR 7,C_SP,C_UR,SR 22,C_H,C_UL,SR 7,C_SP,C_V
  .byte C_UR,SR 38,C_H,C_UL,C_END

.export cartDetected
cartDetected:
  .lobytes $0400 + 5 * 40 + 15
  .hibytes $0400 + 5 * 40 + 15
  screenLine SC PINK, "YES (no PRG autostart)",C_END

.export cartNotDetected
cartNotDetected:
  .lobytes $0400 + 5 * 40 + 15
  .hibytes $0400 + 5 * 40 + 15
  screenLine "NO",C_END

.export kernalTab
kernalTab:
  .lobytes $0400+(7)*40+8
  .hibytes $0400+(7)*40+8
  screenLine SC COLOR_BORDER, C_DR,SR 8,C_H,C_DL, SC COLOR_DISABLED, SR 5,C_H,C_DL,SR 6,C_H,C_DL
  screenLine SC COLOR_BORDER, C_V,SC WHITE, " KERNAL ",SC COLOR_BORDER, C_V, SC COLOR_DISABLED," ",SC WHITE,"P",SC COLOR_DISABLED,"RG ", C_V, " ",SC WHITE,"C",SC COLOR_DISABLED,"ART ",C_V
  screenLine SC COLOR_BORDER, C_VR,SR 8,C_H,C_HU,SR 13,C_H,C_END

.export prgTab
prgTab:
  .lobytes $0400+(7)*40+8
  .hibytes $0400+(7)*40+8
  screenLine SC COLOR_DISABLED, C_DR,SR 8,C_H, SC COLOR_BORDER,C_DR, SR 5,C_H,C_DL,SC COLOR_DISABLED, SR 6,C_H,C_DL
  screenLine C_V,SC WHITE, " K",SC COLOR_DISABLED,"ERNAL ",SC COLOR_BORDER, C_V, SC WHITE," PRG ", SC COLOR_BORDER, C_V,SC WHITE," C",SC COLOR_DISABLED,"ART ",C_V
  screenLine SC COLOR_BORDER, C_DR,SR 8,C_H,C_HU,SR 5,C_H,C_HU,SR 7,C_H,C_END

.export cartTab
cartTab:
  .lobytes $0400+(7)*40+8
  .hibytes $0400+(7)*40+8
  screenLine SC COLOR_DISABLED, C_DR,SR 8,C_H, C_DR, SR 5,C_H,SC COLOR_BORDER,C_DR, SR 6,C_H,C_DL
  screenLine SC COLOR_DISABLED, C_V,SC WHITE, " K",SC COLOR_DISABLED,"ERNAL ", C_V, SC WHITE," P", SC COLOR_DISABLED, "RG ", SC COLOR_BORDER, C_V,SC WHITE," CART ",SC COLOR_BORDER,C_V
  screenLine SC COLOR_BORDER, C_DR,SR 14,C_H,C_HU,SR 6,C_H,C_HU,C_END

.export cartFound
cartFound:
  .lobytes $0400+(5)*40+18
  .hibytes $0400+(5)*40+18
  .byte SC WHITE,"YES",C_END

.export noCartFound
noCartFound:
  .lobytes $0400+(5)*40+18
  .hibytes $0400+(5)*40+18
  .byte SC WHITE,"NO",C_END
