This project contains scripts to build the ST Microelectronics STM32746G-Discovery/Demonstration 
project using the GCC toolchain under Linux (the original supports closed source toolchains only).

By executing *create_makefile_inc.sh* the file *makefile.inc* is created containing makefile variables
extracted from the EWARM project file (XML) of the original STM32746G-Discovery/Demonstration project.

Together with *Makefile* the Discovery Demo project could then be built.

Further added in *Makefile* are rules for flash and debug via openocd.


Tools and Sources used
==============
- Linux host

- STM32CubeF7 v1.3.0
  * from http://www2.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32cube-embedded-software/stm32cubef7.html

- GCC ARM Embedded (bare-metal) toolchain which supports cortex-m7
  * binary from: https://launchpad.net/gcc-arm-embedded
  * tested with: https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q1-update/+download/gcc-arm-none-eabi-5_3-2016q1-20160330-linux.tar.bz2
 
- OpenOCD with cortex-m7 and STM32746G-Discovery support
  if the one in the distribution does not suppurt cortex-m7 build it by:
  * $ git clone http://openocd.zylin.com/p/openocd.git openocd-stm32f7
  * $ cd openocd-stm32f7/
  * $ ./bootstrap && ./configure --enable-stlink && make -j4
  * $ sudo make install


Then Build the discovery project
==============
- unzip *en.stm32cubef7.zip*
- git clone this project (side by to side to the the STM32Cube_FW* folder)
- ev. adapt *STM32_CUBE_F7* variable in *create_makefile_inc.sh*
- execute *./create_makefile_inc.sh*
- *make*
- *make flash*


Limitations of current openocd flash
==============
Unfortunately the QSPI flash on the discovery board can't be written by openocd 
wheras write errors starting from 0x90000000 are reported and graphics on the
demo might be scrambled.

To workaround the QSPI flash might be programmed under windows by the 'stlink' 
programmer software from ST Microelectronics 
 * for QSPI support enable **External Loader > N25Q128A_STM32F746G-DISCO** in the *stlink* Utility

Or you adapt the STM32746G-Discovery/Demonstration software that QSPI "firmware update" 
is possible via a SD card ;-)


Have fun


