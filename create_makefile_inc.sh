#! /bin/sh

# this script rebuilds makefile.inc to get the path of all sources of the STM32746G-Discovery/Demonstration project
# the paths are extracted from the EWARM Project XML file

STM32_CUBE_F7=`ls -d ../STM32Cube_FW_F7_V1.*`

DISCODEMO=$STM32_CUBE_F7/Projects/STM32746G-Discovery/Demonstration/EWARM
EWP=$DISCODEMO/Project.ewp

# Remark: the PROJ_DIR variable below is only needed as relative path reference - the resulting project ist built in the current directory!
echo "PROJ_DIR = $DISCODEMO" > makefile.inc 

# INCLUDES
echo 'INCLUDES = -I .' >> makefile.inc 
grep '<state>$PROJ_DIR$.*</state>' $EWP | grep -v stm32f746g.icf | sed -re 's/\s*<state>\$PROJ_DIR\$/INCLUDES +=  -I \$(PROJ_DIR)/' -e 's/<\/state>//' |  tr '\\' '/' >> makefile.inc
echo >> makefile.inc

# SOURCES_C
grep '<name>$PROJ_DIR$.*.c</name>' $EWP | sed -re 's/\s*<name>\$PROJ_DIR\$/SOURCES_C += \$(PROJ_DIR)/' | sed -re 's/<\/name>//' | tr '\\' '/'  >> makefile.inc
echo >> makefile.inc

# LIBRARIES
grep '<name>$PROJ_DIR$.*.a</name>' $EWP | sed -re 's/\s*<name>\$PROJ_DIR\$/LIBRARIES += \$(PROJ_DIR)/' | sed -re 's/<\/name>//' | tr '\\' '/'  >> makefile.inc
echo >> makefile.inc

# SOURCES_S
# assembler sources (*.s) from IAR project are not suitable because gcc has different assembler syntax 
# use startup code from gcc template available in STM32Cube
echo 'SOURCES_S += $(PROJ_DIR)/../../../../Drivers/CMSIS/Device/ST/STM32F7xx/Source/Templates/gcc/startup_stm32f746xx.s' >> makefile.inc
echo >> makefile.inc

# use ldscript of another STM32Cube project
echo 'LDSCRIPT = $(PROJ_DIR)/../SW4STM32/STM32F7-DISCO/STM32F746NGHx_FLASH.ld' >> makefile.inc

###
# the discovery demo project does not reference c functions which need the c heap 
# but if you reference c library function which needs heap, enable following lines to add/correct syscall.c containing _sbrk() from other STM32Cube project
# mention that the c heap is not thread-save/reentrant which is a a problem when programming multitasking...
#echo 'SOURCES_C += $(PROJ_DIR)/../../../STM32756G_EVAL/Applications/USB_Host/HID_RTOS/SW4STM32/syscalls.c' >> makefile.inc
#sed  's/extern char end asm("end");/extern char end;/'   $DISCODEMO/../../../STM32756G_EVAL/Applications/USB_Host/HID_RTOS/SW4STM32/syscalls.c >syscalls.c
#echo 'SOURCES_C += syscalls.c' >> makefile.inc


####
# bugfixes

# take GCC variant of STM32Cube sourcefiles where IAR is referenced
sed -i -e 's/IAR/GCC/' makefile.inc

# create empty file intrinsics.h (seems EWARM has this)
touch intrinsics.h
 
# correct upper/lower case problems of STM32Cube_FW_F7_V1.3.0
sed -i -e 's!$(PROJ_DIR)/../Core/inc!$(PROJ_DIR)/../Core/Inc!' makefile.inc  # correct wrong case
sed -i -e 's/"gui.h"/"GUI.h"/'  $DISCODEMO/../Core/Inc/main.h
sed -i -e 's/"gui.h"/"GUI.h"/'  $DISCODEMO/../Core/Inc/main.h
[ -e $DISCODEMO/../../../Middlewares/ST/STemWin/inc/DIALOG.h ] && mv $DISCODEMO/../../../Middlewares/ST/STemWin/inc/DIALOG.h $DISCODEMO/../../../../Middlewares/ST/STemWin/inc/dialog.h
sed -i -e 's/"DIALOG.h"/"dialog.h"/' $DISCODEMO/../Core/Src/k_bsp.c
sed -i -e 's/"DIALOG.h"/"dialog.h"/' $DISCODEMO/../../../STM32756G_EVAL/Applications/STemWin/STemWin_SampleDemo/Demo/GUIDEMO_Skinning.c
sed -i -e 's/"DIALOG.h"/"dialog.h"/' $DISCODEMO/../../../../Middlewares/ST/STemWin/inc/MULTIPAGE.h
sed -i -e 's/"Dialog.h"/"dialog.h"/' $DISCODEMO/../STemWin_Addons/STM32746G_Discovery_STemWin_Addons.h

# end
