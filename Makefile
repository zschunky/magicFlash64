# 
# Copyright (c) 2019 Andreas Zschunke
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 


## common build part ##

BUILD_DIR=build

VERSION_FILE=$(BUILD_DIR)/versions.txt
all: avr c64 $(VERSION_FILE)
clean:
	rm -rf $(BUILD_DIR)/*

VER_PCB_MAJOR=0
VER_PCB_MINOR=2

VER_MENU_MAJOR=0
VER_MENU_MINOR=5

VER_PROGRAMMER_MAJOR=0
VER_PROGRAMMER_MINOR=4

VER_FW_MAJOR=1
VER_FW_MINOR=0

VER_TEST_MAJOR=0
VER_TEST_MINOR=1

VER_RECOVERY=1

FW_ADDR=0x280
RECOVERY_ADDR=0x80
RECOVERY_IMPL_ADDR=0xa0

DEFINES=-D VER_MENU_MAJOR=$(VER_MENU_MAJOR) -D VER_MENU_MINOR=$(VER_MENU_MINOR) -D VER_PROGRAMMER_MAJOR=$(VER_PROGRAMMER_MAJOR) -D VER_PROGRAMMER_MINOR=$(VER_PROGRAMMER_MINOR) -D VER_FW_MAJOR=$(VER_FW_MAJOR) -D VER_FW_MINOR=$(VER_FW_MINOR) -D VER_TEST_MAJOR=$(VER_TEST_MAJOR) -D VER_TEST_MINOR=$(VER_TEST_MINOR) -D VER_RECOVERY=$(VER_RECOVERY) -D FW_ADDR=$(FW_ADDR) -D RECOVERY_ADDR=$(RECOVERY_ADDR)

## AVR build part ##

AVR_BUILD_DIR=$(BUILD_DIR)/avr

AVR=atmega48
AVR_TARGET=mf64-firmware.bin
AVR_CFLAGS+=-Wl,-Ttext=$(FW_ADDR),--section-start=.boot=0x0000,--section-start=.recoveryLookup=$(RECOVERY_ADDR),--section-start=.recovery=$(RECOVERY_IMPL_ADDR),-Map,$(AVR_BUILD_DIR)/avr.map,--cref $(DEFINES)


AVR_SRC=main.S cmdFwUpd.S cmdGetEeprom.S cmdGetRam.S cmdGetVersion.S cmdMcType.S cmdReset.S cmdSelect.S cmdSetEeprom.S cmdTest.S cmdWrModeErase.S cmdWrModeReset.S ram.S \
    cmdGetDefault.S cmdGetPrev.S cmdGetSelected.S cmdLed.S cmdSelectAfterInt.S cmdSelectPrev.S cmdSetDefault.S cmdSetRam.S cmdWrModeAutoSelect.S cmdWrModeProgram.S \
		eeprom.S led.S reset.S restore.S sendByte.S setSelect.S cmdSelectAfterRestoreInt.S boot.S cmdGetMode.S cmdGetRecoveryVersion.S cmdRecoveryUpd.S recovery.S

AVR_CC=avr-gcc 
AVR_OBJDUMP=avr-objdump
AVR_SIZE=avr-size
AVR_OBJ2HEX=avr-objcopy
AVR_CFLAGS+=-g -Wall -mmcu=$(AVR) -std=gnu99 -O2 -fdata-sections -ffunction-sections #-Wl,--gc-sections #-fdiagnostics-color=always

VPATH+=$(AVR_BUILD_DIR) src/avr

AVR_OBJECTS=$(patsubst %.S,$(AVR_BUILD_DIR)/%.o,$(patsubst %.c,$(AVR_BUILD_DIR)/%.o,$(filter-out %.enum,$(AVR_SRC))))
AVR_DEPS=$(patsubst %.S,$(AVR_BUILD_DIR)/%.d,$(patsubst %.c,$(AVR_BUILD_DIR)/%.d,$(filter-out %.enum,$(AVR_SRC))))

DEFAULT_D64=src/c64/default.d64


-include $(AVR_DEPS)

avr: $(BUILD_DIR)/$(AVR_TARGET)


$(AVR_BUILD_DIR)/%.o: %.S Makefile config.inc
	@mkdir -p $(AVR_BUILD_DIR)
	$(AVR_CC) -I$(AVR_BUILD_DIR) $(AVR_CFLAGS) -c -MMD $< -o $@

$(AVR_BUILD_DIR)/$(patsubst %.bin,%.elf,$(AVR_TARGET)): $(AVR_OBJECTS)
	$(AVR_CC)  $(AVR_CFLAGS) $(AVR_OBJECTS) -o $@
	($(AVR_OBJDUMP) -S --disassemble -p -w -t $@; $(AVR_OBJDUMP) -j.data  -s -w $@) >$(AVR_BUILD_DIR)/$(AVR_TARGET).lst
	$(AVR_SIZE) -C --mcu=$(AVR) $@

$(BUILD_DIR)/%.bin: $(AVR_BUILD_DIR)/%.elf
	$(AVR_OBJ2HEX) -R .eeprom -O binary --gap-fill 0xff $< $@

## C64 build part ##

C64_CC=cl65 -t c64
C64_LD=ld65
C64_CFLAGS=-Oir --asm-include-dir $(C64_BUILD_DIR) --bin-include-dir $(BUILD_DIR) $(patsubst -D%,--asm-define%,$(DEFINES))
C64_LDFLAGS_MENU=-Oir  -C src/c64/kernal.cfg
C64_LDFLAGS_PRG=-C src/c64/prgAsm.cfg
C64_DA=da65 -S '$$e000' --comments 4
C64_DAPRG=da65 -S '$$07ff' --comments 4
C64_FD=scripts/fd65.py
ASMDEPINC=scripts/asmDepInc.py
ULTIMATE_DIR=/Usb1
FTPPUT=scripts/ftpPut.py

C64_BUILD_DIR=$(BUILD_DIR)/c64
VPATH+=. $(C64_BUILD_DIR) src/c64

ASM_INC=$(wildcard *.inc)

SRC_MENU=magicFlash64Lib.s mainMenu.s key.s screenCpy.s select.s zeropage.s selectSlotMenu.s kernalImpl.s num.s screenNum.s textMenuEn.s injectInt.s pla.s \
				 qrcode.s menuFrame.s tick.s
OBJECTS_MENU=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(patsubst %.c,$(C64_BUILD_DIR)/%.o,$(SRC_MENU)))
TARGET_MENU=mf64-menu.bin

SRC_PROGRAMMER=magicFlash64Lib.s magicFlash64LibPgm.s mainProgrammer.s key.s screenCpy.s select.s selectSlot.s selectFile.s slot.s petscii2screen.s zeropage.s pla.s \
				backupDisk.s crc.s num.s screenNum.s status.s textProgrammerEn.s patchTable.s backup.s backupReu.s c64Kernal.s backupGeoRam.s backupSelect.s breakPoint.s \
				qrcode.s tick.s input.s

OBJECTS_PROGRAMMER=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(patsubst %.c,$(C64_BUILD_DIR)/%.o,$(SRC_PROGRAMMER)))
TARGET_PROGRAMMER=mf64-programmer.prg

SRC_UPD=magicFlash64Lib.s magicFlash64LibPgm.s mainUpd.s zeropage.s breakPoint.s key.s
OBJECTS_UPD=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(patsubst %.c,$(C64_BUILD_DIR)/%.o,$(SRC_UPD)))
TARGET_UPD=mf64-fw-update.prg

SRC_RECOVERY_UPD=magicFlash64Lib.s magicFlash64LibPgm.s mainRecoveryUpd.s zeropage.s breakPoint.s key.s
OBJECTS_RECOVERY_UPD=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(patsubst %.c,$(C64_BUILD_DIR)/%.o,$(SRC_RECOVERY_UPD)))
TARGET_RECOVERY_UPD=mf64-recoveryupd.prg

SRC_TEST=magicFlash64Lib.s mainTest.s  zeropage.s screenCpy.s num.s screenNum.s
OBJECTS_TEST=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(patsubst %.c,$(C64_BUILD_DIR)/%.o,$(SRC_TEST)))
TARGET_TEST=mf64-test.prg

TARGET_D64=magic-flash64.d64

C64_SRC=$(sort $(SRC_MENU) $(SRC_PROGRAMMER) $(SRC_UPD) $(SRC_TEST))
C64_OBJ=$(patsubst %.s,$(C64_BUILD_DIR)/%.o,$(C64_SRC))

C64_DEPS=$(patsubst %.o,%.d,$(C64_OBJ))

c64: $(BUILD_DIR)/$(TARGET_UPD) $(BUILD_DIR)/$(TARGET_PROGRAMMER) $(BUILD_DIR)/$(TARGET_TEST) $(BUILD_DIR)/$(TARGET_MENU) $(BUILD_DIR)/$(TARGET_RECOVERY_UPD) $(BUILD_DIR)/$(TARGET_D64)

$(C64_BUILD_DIR)/%.d: %.s Makefile
	@mkdir -p $(C64_BUILD_DIR)
	$(ASMDEPINC) $< $(patsubst %.d,%.o,$@) $@ $(patsubst %.d,%.inc,$@) $(C64_BUILD_DIR)

-include $(C64_DEPS)


$(C64_BUILD_DIR)/%.o: %.c Makefile
	@mkdir -p $(C64_BUILD_DIR)
	$(C64_CC) -o $@ -I$(C64_BUILD_DIR) $(C64_CFLAGS) -c $< 

$(C64_BUILD_DIR)/mainUpd.o: $(BUILD_DIR)/$(AVR_TARGET)

$(C64_BUILD_DIR)/%.o: %.s Makefile $(ASM_INC)
	@mkdir -p $(C64_BUILD_DIR)
	$(C64_CC) -o $@ -I$(C64_BUILD_DIR) $(C64_CFLAGS) -c $<


$(BUILD_DIR)/$(TARGET_MENU): $(OBJECTS_MENU) Makefile
	$(C64_CC) $(C64_LDFLAGS_MENU) $(OBJECTS_MENU) -o $@ -Ln $(C64_BUILD_DIR)/$(patsubst %.bin,%.sym,$(TARGET_MENU)) 
	$(C64_DA) $@ -o $(C64_BUILD_DIR)/$(patsubst %.bin,%.orig.s,$(TARGET_MENU))
	$(C64_FD) $(C64_BUILD_DIR)/$(patsubst %.bin,%.orig.s,$(TARGET_MENU)) $(C64_BUILD_DIR)/$(patsubst %.bin,%.sym,$(TARGET_MENU)) > $(C64_BUILD_DIR)/$(patsubst %.bin,%.s,$(TARGET_MENU))

$(BUILD_DIR)/$(TARGET_PROGRAMMER): $(OBJECTS_PROGRAMMER) Makefile
	$(C64_LD) $(C64_LDFLAGS_PRG) $(OBJECTS_PROGRAMMER) -o $@ -Ln $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_PROGRAMMER)) 
	$(C64_DAPRG) $@ -o $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_PROGRAMMER))
	$(C64_FD) $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_PROGRAMMER)) $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_PROGRAMMER)) > $(C64_BUILD_DIR)/$(patsubst %.prg,%.s,$(TARGET_PROGRAMMER))

$(BUILD_DIR)/$(TARGET_UPD): $(OBJECTS_UPD) Makefile
	$(C64_LD) $(C64_LDFLAGS_PRG) $(OBJECTS_UPD) -o $@ -Ln $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_UPD)) 
	$(C64_DAPRG) $@ -o $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_UPD))
	$(C64_FD) $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_UPD)) $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_UPD)) > $(C64_BUILD_DIR)/$(patsubst %.prg,%.s,$(TARGET_UPD))

$(BUILD_DIR)/$(TARGET_RECOVERY_UPD): $(OBJECTS_RECOVERY_UPD) Makefile
	$(C64_LD) $(C64_LDFLAGS_PRG) $(OBJECTS_RECOVERY_UPD) -o $@ -Ln $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_RECOVERY_UPD)) 
	$(C64_DAPRG) $@ -o $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_RECOVERY_UPD))
	$(C64_FD) $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_RECOVERY_UPD)) $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_RECOVERY_UPD)) > $(C64_BUILD_DIR)/$(patsubst %.prg,%.s,$(TARGET_RECOVERY_UPD))

$(BUILD_DIR)/$(TARGET_TEST): $(OBJECTS_TEST) Makefile
	$(C64_LD) $(C64_LDFLAGS_PRG) $(OBJECTS_TEST) -o $@ -Ln $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_TEST)) 
	$(C64_DAPRG) $@ -o $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_TEST))
	$(C64_FD) $(C64_BUILD_DIR)/$(patsubst %.prg,%.orig.s,$(TARGET_TEST)) $(C64_BUILD_DIR)/$(patsubst %.prg,%.sym,$(TARGET_TEST)) > $(C64_BUILD_DIR)/$(patsubst %.prg,%.s,$(TARGET_TEST))

$(BUILD_DIR)/$(TARGET_D64): $(BUILD_DIR)/$(TARGET_UPD) $(BUILD_DIR)/$(TARGET_PROGRAMMER) $(BUILD_DIR)/$(TARGET_TEST) $(BUILD_DIR)/$(TARGET_MENU) $(BUILD_DIR)/$(TARGET_RECOVERY_UPD)
	cp $(DEFAULT_D64) $@
	c1541 -attach $@ $(foreach var,$^,-write $(var) $(shell echo $(patsubst %.prg,%,$(patsubst $(BUILD_DIR)/%,%,$(var))) | tr A-Z a-z))

put: $(BUILD_DIR)/$(TARGET_D64) $(BUILD_DIR)/$(TARGET_UPD) $(BUILD_DIR)/$(TARGET_PROGRAMMER) $(BUILD_DIR)/$(TARGET_TEST) $(BUILD_DIR)/$(TARGET_RECOVERY_UPD)
	$(FTPPUT) Ultimate-II $(ULTIMATE_DIR) $^

# version file
$(VERSION_FILE): Makefile
	echo pcb: $(VER_PCB_MAJOR).$(VER_PCB_MINOR) > $(VERSION_FILE)
	echo $(TARGET_MENU): $(VER_MENU_MAJOR).$(VER_MENU_MINOR) >> $(VERSION_FILE)
	echo $(TARGET_PROGRAMMER): $(VER_PROGRAMMER_MAJOR).$(VER_PROGRAMMER_MINOR) >> $(VERSION_FILE)
	echo $(TARGET_TEST): $(VER_TEST_MAJOR).$(VER_TEST_MINOR) >> $(VERSION_FILE)
	echo $(TARGET_UPD): $(VER_FW_MAJOR).$(VER_FW_MINOR) >> $(VERSION_FILE)
	echo $(AVR_TARGET): $(VER_FW_MAJOR).$(VER_FW_MINOR) >> $(VERSION_FILE)
	echo $(TARGET_RECOVERY_UPD): $(VER_RECOVERY) >> $(VERSION_FILE)




