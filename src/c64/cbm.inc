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

;
; Include file for the Commdore 6502 machines
;


;-----------------------------------------------------------------------------
; Subroutines available in the CBM jump table
;

.import C64MODE
.import SWAPPER
.import SETBNK

.import CINT
.import IOINIT
.import RAMTAS
.import VECTOR
.import RESTOR
.import SETMSG
.import SECOND
.import TKSA
.import MEMTOP
.import MEMBOT
.import SCNKEY
.import SETTMO
.import ACPTR
.import CIOUT
.import UNTLK
.import UNLSN
.import LISTEN
.import TALK
.import READST
.import SETLFS
.import SETNAM
.import OPEN
.import CLOSE
.import LOAD
.import SAVE
.import SETTIM
.import RDTIM
.import SCREEN
.import PLOT
.import IOBASE
.import CHKIN
.import CKOUT
.import CLRCH
.import BASIN
.import CHRIN
.import BSOUT
.import CHROUT
.import STOP
.import GETIN
.import CLALL
.import UDTIM

;-----------------------------------------------------------------------------
; Device numbers
;

CBMDEV_KBD      = 0
CBMDEV_DATASETTE= 1
CBMDEV_RS232    = 2
CBMDEV_SCREEN   = 3

;-----------------------------------------------------------------------------
; Disk stuff
;

MAX_DRIVES      = 23
FIRST_DRIVE     = 8
