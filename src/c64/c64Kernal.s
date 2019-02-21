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

.export KERNAL_CINT
KERNAL_CINT = $FF81
.export KERNAL_IOINIT
KERNAL_IOINIT = $FF84
.export KERNAL_RAMTAS
KERNAL_RAMTAS = $FF87
.export KERNAL_RESTOR
KERNAL_RESTOR = $FF8A
.export KERNAL_VECTOR
KERNAL_VECTOR = $FF8D
.export KERNAL_SETMSG
KERNAL_SETMSG = $FF90
.export KERNAL_SECOND
KERNAL_SECOND = $FF93
.export KERNAL_TKSA
KERNAL_TKSA = $FF96
.export KERNAL_MEMTOP
KERNAL_MEMTOP = $FF99
.export KERNAL_MEMBOT
KERNAL_MEMBOT = $FF9C
.export KERNAL_SCNKEY
KERNAL_SCNKEY = $FF9F
.export KERNAL_SETTMO
KERNAL_SETTMO = $FFA2
.export KERNAL_ACPTR
KERNAL_ACPTR = $FFA5
.export KERNAL_CIOUT
KERNAL_CIOUT = $FFA8
.export KERNAL_UNTLK
KERNAL_UNTLK = $FFAB
.export KERNAL_UNLSN
KERNAL_UNLSN = $FFAE
.export KERNAL_LISTEN
KERNAL_LISTEN = $FFB1
.export KERNAL_TALK
KERNAL_TALK = $FFB4
.export KERNAL_READST
KERNAL_READST = $FFB7
.export KERNAL_SETLFS
KERNAL_SETLFS = $FFBA
.export KERNAL_SETNAM
KERNAL_SETNAM = $FFBD
.export KERNAL_OPEN
KERNAL_OPEN = $FFC0
.export KERNAL_CLOSE
KERNAL_CLOSE = $FFC3
.export KERNAL_CHKIN
KERNAL_CHKIN = $FFC6
.export KERNAL_CHKOUT
KERNAL_CHKOUT = $FFC9
.export KERNAL_CLRCHN
KERNAL_CLRCHN = $FFCC
.export KERNAL_CHRIN
KERNAL_CHRIN = $FFCF
.export KERNAL_CHROUT
KERNAL_CHROUT = $FFD2
.export KERNAL_LOAD
KERNAL_LOAD = $FFD5
.export KERNAL_SAVE
KERNAL_SAVE = $FFD8
.export KERNAL_SETTIM
KERNAL_SETTIM = $FFDB
.export KERNAL_RDTIM
KERNAL_RDTIM = $FFDE
.export KERNAL_STOP
KERNAL_STOP = $FFE1
.export KERNAL_GETIN
KERNAL_GETIN = $FFE4
.export KERNAL_CLALL
KERNAL_CLALL = $FFE7
.export KERNAL_UDTIM
KERNAL_UDTIM = $FFEA
.export KERNAL_SCREEN
KERNAL_SCREEN = $FFED
.export KERNAL_PLOT
KERNAL_PLOT = $FFF0
.export KERNAL_IOBASE
KERNAL_IOBASE = $FFF3
