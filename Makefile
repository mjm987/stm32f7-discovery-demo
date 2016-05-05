# M. Meier: gcc Makefile for STM32F7-Discovery Demonstration 
# derived from Makefile of STM32F7-Discovery-Blinky

PROJECT = discodemo
 
#PREFIX = arm-none-eabi
PREFIX = /opt/gcc-arm-none-eabi-5_3-2016q1/bin/arm-none-eabi

# variables taken from makefile.inc : INCLUDES, SOURCES_C, SOURCES_S, PROJ_DIR, LIBRARIES, LDSCRIPT
# makefile.inc might be recreated from EWARM project file by executing './create_makefile_inc.sh'
include makefile.inc

SOURCES = $(SOURCES_S) $(SOURCES_C) $(SOURCES_CPP)
OBJS = $(SOURCES_S:.s=.o) $(SOURCES_C:.c=.o) $(SOURCES_CPP:.cpp=.o)

################
# Defines
#from Demonstration/SW4STM32/STM32F7-DISCO/.cproject
DEFINES = -DSTM32F756xx -DUSE_HAL_DRIVER -DUSE_STM32746G_DISCOVERY
#DEFINES = -DSTM32 -DSTM32F7 -DSTM32F746xx -DSTM32F746NGHx -DSTM32F746G_DISCO

################
# Compiler/Assembler/Linker/etc

CC = $(PREFIX)-gcc
AS = $(PREFIX)-as
AR = $(PREFIX)-ar
LD = $(PREFIX)-gcc
NM = $(PREFIX)-nm
OBJCOPY = $(PREFIX)-objcopy
OBJDUMP = $(PREFIX)-objdump
READELF = $(PREFIX)-readelf
SIZE = $(PREFIX)-size
GDB = $(PREFIX)-gdb
RM = rm -f

################
# Compiler options

MCUFLAGS = -mcpu=cortex-m7 -mlittle-endian
MCUFLAGS += -mfloat-abi=hard -mfpu=fpv5-sp-d16
MCUFLAGS += -mthumb

#DEBUG_FLAGS = -O0 -g -gdwarf-2
DEBUG_FLAGS = -Os

CFLAGS = -std=c11
CFLAGS += -Wall -Wextra --pedantic
#-fmessage-length=0 -Wno-format -Wno-address -Wno-pointer-sign

CFLAGS_EXTRA = -nostartfiles -fdata-sections -ffunction-sections
CFLAGS_EXTRA += -Wl,--gc-sections -Wl,-Map=$(PROJECT).map

CFLAGS += $(DEFINES) $(MCUFLAGS) $(DEBUG_FLAGS) $(CFLAGS_EXTRA) $(INCLUDES)

LDFLAGS = -static $(MCUFLAGS)
LDFLAGS += -Wl,--start-group -lgcc -lm -lc -lg -lstdc++ -lsupc++ 

# add libraries form makefile.inc
# following variants results in equal elf .text size (the whole libraries seems to be referenced)
#LDFLAGS += $(LIBRARIES)
LDFLAGS += $(addprefix -L, $(dir $(LIBRARIES))) $(addprefix -l:, $(notdir $(LIBRARIES)))

LDFLAGS += -Wl,--end-group -Wl,--gc-sections
LDFLAGS += -T $(LDSCRIPT)
LDFLAGS += -Xlinker -Map -Xlinker $(PROJECT).map

################
# Build rules

all: $(PROJECT).hex

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -O ihex $(PROJECT).elf $(PROJECT).hex

$(PROJECT).elf: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(PROJECT).elf
	$(SIZE) -A $(PROJECT).elf

clean:
	$(RM) $(OBJS) $(PROJECT).elf $(PROJECT).hex $(PROJECT).map


# ---------------------------------------------------------------------------
# Rule flash: flashes by OpenOCD 
# Rule gdbserver: starts OpenOCD for debugging in gdbserver mode
# Rule killgdbserver: stops any OpenOCD in gdbserver mode

# openocd had to be rebuild for stm32f7discovery support
#  git clone http://openocd.zylin.com/p/openocd.git openocd-stm32f7
#  cd openocd-stm32f7/
#  ./bootstrap
#  ./configure --enable-stlink
#  make -j4
# sudo make install

OPENOCD = openocd
OOCD_INIT  += -f board/stm32f7discovery.cfg
OOCD_INIT  += -c init
OOCD_INIT  += -c "reset init"
OOCD_FLASH = -c "reset halt"
#OOCD_FLASH += -c "targets"
#OOCD_FLASH += -c "flash protect 0 0 11 off"
OOCD_FLASH += -c "flash erase_address 0x08000000 0x100000"
OOCD_FLASH += -c "flash write_image erase $(PROJECT).elf"
#OOCD_FLASH += -c "flash write_image erase $(PROJECT).hex 0 ihex"
OOCD_FLASH += -c "verify_image $(PROJECT).elf"
#OOCD_FLASH += -c "verify_image $(PROJECT).hex 0 ihex"
OOCD_FLASH += -c "reset run"
OOCD_FLASH += -c shutdown
	
flash: $(PROJECT).elf
	$(OPENOCD)  $(OOCD_INIT) $(OOCD_FLASH)

gdbserver:
	$(OPENOCD)  $(OOCD_INIT)  # -c "lm3s3748.cpu configure -rtos auto;"

killgdbserver:
ifdef windir
	taskkill /IM $(OPENOCD).exe /F
else
	killall openocd
	@#echo "shutdown" | telnet localhost 4444
endif	

# EOF
