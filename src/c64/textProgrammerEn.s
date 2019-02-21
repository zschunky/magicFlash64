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
.macpack cbm
.include "status.inc"
.include "magicFlash64Colors.inc"
.include "frame.inc"
.include "screenCpy.inc"

.define STATUS_WIDTH 36

.code

;incBegin
.define TYPE_WIDTH 11
;incEnd
.export typeFrame
typeFrame:
  frameTitle "SELECT TYPE", TYPE_WIDTH+2, 11

.export typesName
typesName:
  .byte 5
  scrcode "basic"
  .byte 6
  scrcode "kernal"
  .byte 3
  scrcode "prg"
  .byte 4
  scrcode "cart"
  .byte 4
  scrcode "menu"
  .byte 0

.data
.export statusFrame
statusFrame:
  frameTitle "STATUS", STATUS_WIDTH+2, 5

statusText statusCheckSlot,            "CHECK SLOT ","XX"
statusText statusUnexpErase,           "ERASE MISMATCH SLOT ", "XX <SPACE>"
statusText statusUnexpCrc,             "CRC MISMATCH SLOT ", "XX <SPACE>"
statusText statusErrorPgm,             "PGM-ERR SLOT ", "XX <SPACE>"
statusText statusErrorErase,           "ERASE-ERR SLOT ", "XX-","XX <SPACE>"
statusText statusNotEnoughFree,        "NOT ENOUGH FREE SLOTS <SPACE>"
statusText statusLoadingError,         "LOADING ERROR <SPACE>"
statusText statusLoadingErrorSlot,     "LOAD ERR SLOT ", "XX <SPACE FOR RETRY>"
statusText statusErrorPgmErsActKernal, "E/P ACTIVE KERNAL NOT ALLOWED <SP>"
statusText statusWrBackupError,        "WR-ERR BACKUP, <SPACE FOR RETRY>"
statusText statusRdRestoreError,       "RD-ERR RESTORE, <SPACE FOR RETRY>"
statusText statusErase,                "ERASE SLOTS ","XX-","XX"
statusText statusReProgram,            "REPROGRAM SLOT ","XX"
statusText statusProgram,              "PROGRAM SLOT ","XX"
statusText statusLoading,              "LOADING SLOT ","XX"
statusText statusBackup,               "BACKUP SLOT ","XX"
statusText statusRestore,              "RESTORE SLOT ","XX"
statusText statusLoadingDir,           "LOADING DIRECTORY"



.export slotScreen
slotScreen:
  .lobytes $0400
  .hibytes $0400
  .byte $f0 + COLOR_BORDER,112,$80+38,64,110
  .byte 93,$f0 + COLOR_TITLE
     scrcode "magicFlash64 programmer v" ; len 24
.export slotScreenProgVer
slotScreenProgVer:
     .byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $f0 + COLOR_HELP 
     scrcode "F1"
     .byte $f0 + COLOR_BORDER, 93
  .byte 93,$f0 + COLOR_FW
     scrcode "magicFlash64 firmware v" ; len 22
.export slotScreenFwVer
slotScreenFwVer:
     .byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $f0 + COLOR_HELP 
     scrcode "HELP"
     .byte $f0 + COLOR_BORDER, 93
  .byte 107,$80+38,64,115
  .repeat 20
    .byte 93,$80+38,$20,93
  .endrepeat
  .byte 109,$80+38,64,125,$80

;incBegin
.define BACKUP_SELECT_WIDTH 30
;incEnd
.export backupSelectFrame
backupSelectFrame:
  frameTitle "SELECT TEMPORARY BACKUP DEVICE", 32, 16

.export backupSelectNames
backupSelectNames:
  .byte 7
  scrcode "DRIVE 8"
  .byte 7
  scrcode "DRIVE 9"
  .byte 8
  scrcode "DRIVE 10"
  .byte 8
  scrcode "DRIVE 11"
  .byte 3
  scrcode "REU"
  .byte 6
  scrcode "GEORAM"
  .byte 0


.export typeScreenLo
typeScreenLo:
  .repeat 7,i
    frameAddrTitleLo 13, 11,i * 40
  .endrepeat
.export typeScreenHi
typeScreenHi:
  .repeat 7,i
    frameAddrTitleHi 13, 11,i * 40
  .endrepeat
.export backupSelectScreenLo
backupSelectScreenLo:
  .repeat 11,i
    frameAddrTitleLo 32, 16, i * 40
  .endrepeat
.export backupSelectScreenHi
backupSelectScreenHi:
  .repeat 11,i
    frameAddrTitleHi 32, 16, i * 40
  .endrepeat

.data
.export dirScreen
dirScreen:
  frameTitle "SELECT FILE FOR SLOT XX",25,21

.export fileScreenLo
fileScreenLo:
  .repeat 17,i
    frameAddrTitleLo 25, 21, i * 40
  .endrepeat
.export fileScreenHi
fileScreenHi:
  .repeat 17,i
    frameAddrTitleHi 25, 21, i * 40
  .endrepeat


.export helpFrame
helpFrame:
  frameTitle "HELP", 38, 23

.export help1
help1:
  
  frameAddrTitle 38,23
  .byte $f0+WHITE
  screenLine $80+36,32                                                                       ;
  screenLine 32, 112, $80+8, 64,                        " slot number              "         ;+-------- slot number
  screenLine 32, 93, 32, 32, 112, $80+5, 64,            " action to be done:       "         ;|  +----- action to be done:
  screenLine 32, 93, 32, 32, 93, $80+8, 32,                "E...erase              "         ;|  |        E...erase
  screenLine 32, 93, 32, 32, 93, $80+8, 32,                "P...program            "         ;|  |        P...program
  screenLine 32, 93, 32, 32, 93, $80+8, 32,                "R...reprogram          "         ;|  |        R...reprogram
  screenLine 32, 93, 32, 32, 93, 32, 32, 112, 64, 64,   " slot type:               "         ;|  |  +-- slot type:
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "B...basic              "         ;|  |  |     B...basic
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "K...kernal             "         ;|  |  |     K...kernal
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "M...menu               "         ;|  |  |     M...menu
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "P...program            "         ;|  |  |     P...program
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "C...cartridge          "         ;|  |  |     C...cartridge
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "E...empty              "         ;|  |  |     E...empty
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, $80+5, 32,    "+...follow up slot     "         ;|  |  |     +...follow up slot
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, 32, 112,   " slot name                "         ;|  |  | + slot name
  screenLine 32, 93, 32, 32, 93, 32, 32, 93, 32, 93, $80+26,32                               ;|  |  | |
  screenLine                                  " 00-EP-B-Basic                      "         ;00-EP-B-Basic
  screenLine $80+36,32                                                                       ;
  screenLine                                   "       <SPACE> for next page       ", $80    ;     <SPACE> for next page

.export help2
help2:
  frameAddrTitle 38,23
  .byte $f0+WHITE
  screenLine "                                    "
  screenLine " keyboard keys                      "
  screenLine "       UP/DOWN...navigate           "
  screenLine "           0-9...jump to slot (2    "
  screenLine "                 strokes required)  "
  screenLine "             P...mark slot to be    "
  screenLine "                 programmed         "
  screenLine "             E...mark slot to be    "
  screenLine "                 erased             "
  screenLine "             D...set default        "
  screenLine " <cbm>-8,9,0,1...select drive       "
  screenLine "             T...change slot type   "
  screenLine "             V...view first 1000    "
  screenLine "                 byte on the screen "
  screenLine "             U...undo all           "
  screenLine "            F7...apply changes      "
  screenLine "             B...boot slot          "
  screenLine "                                    "
  screenLine "       <SPACE> for next page        ",$80

.export help3
help3:
  frameAddrTitle 38,23
  .byte $f0+WHITE
  screenLine "                                    "
  screenLine " To program a slot navigate to the  "
  screenLine " desired slot and click P. A file   "
  screenLine " dialog will open where you can     "
  screenLine " select your file to be programmed. "
  screenLine "                                    "
  screenLine " In case the given slot is not      "
  screenLine " empty it will be marked to be      "
  screenLine " erased.                            "
  screenLine "                                    "
  screenLine " By default every slot is loaded    "
  screenLine " as kernal. Click T to change the   "
  screenLine " slot type.                         "
  screenLine "                                    "
  screenLine " To write the changes to the flash  "
  screenLine " click F7.                          "
  screenLine "                                    "
  screenLine "                                    "
  screenLine "     <SPACE> to close this help     ",$80
