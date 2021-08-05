
TPATH := /opt/riscv32i/bin/
PREFIX := riscv32-unknown-elf
XSCT := /opt/vivado191/SDK/2019.1/bin/xsct/
DEPS:=  -I../.. -I../../lib  -I../../bsp
CC_FLAGS:= -march=rv32i  -Wall  -mpreferred-stack-boundary=4  -ffreestanding $(DEPS) -std=gnu99  -pedantic

#CC_FLAGS:= -march=rv32i -Wall  -fomit-frame-pointer -ffreestanding -fno-builtin -I../.. -I../../lib -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
AS_FLAGS:= -march=rv32i 
LD_FLAGS:= -L /opt/riscv32i/lib/gcc/riscv32-unknown-elf/10.1.0   -l:libgcc.a 
#LD_FLAGS:= -march=rv32i -nostartfiles -L../lib \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections
CC := $(TPATH)$(PREFIX)-gcc
LD := $(TPATH)$(PREFIX)-ld
OBJCOPY := $(TPATH)$(PREFIX)-objcopy
OBJDUMP := $(TPATH)$(PREFIX)-objdump
MEM_SCRIPT:= python3 ../../../sw/scripts/rom_.py 


start.o: 
	$(TPATH)$(PREFIX)-as  $(AS_FLAGS) ../../bsp/start.S -o build/start.o

main.o:
	$(CC)  $(CC_FLAGS) -c src/main.c -o build/main.o 
main.elf: main.o start.o
	$(LD)   build/start.o build/main.o -T ../../bsp/ldscript -o build/main.elf $(LD_FLAGS)
main.v: main.elf
	$(OBJCOPY) -O verilog  build/main.elf  build/main.mem
main.hex: main.elf
	$(OBJCOPY) -O ihex  build/main.elf  build/main.hex
main.lst:
	$(OBJDUMP) --source --all-headers --demangle  --line-numbers --wide "build/main.elf" > "build/main.lst"
main.mem: main.v
	$(MEM_SCRIPT) ./build/main.mem
	cp -f build/main.mem ../../../rtl/memory/
rom: main.mem main.lst main.hex
	
all: rom

#FLASH:
#	$(XSCT) connect
#	$(XSCT) exec bootgen -arch zynq -image ./output/output.bif -w -o ./output/BOOT.bin
#COPY_OUTPUTS:	
#	cp ../vivado/AUK-V/AUK-V.sdk/auk-clock/Debug/auk-clock.elf -f ./output/arm.elf
#	cp ../vivado/AUK-V/AUK-V.sdk/example_led_wrapper_hw_platform_0/example_led_wrapper.bit ./output/fpga.bit

#xsct targets 2
#dow ./output/arm.elf  
#fpga ./output/fpga.bit
#exec bootgen -arch zynq -image output.bif -w -o BOOT.bin
#exec program_flash -f /tmp/wrk/BOOT.bin -flash_type qspi_single
#
#
#
