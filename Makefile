all: yggdrasil

yggdrasil: virt.lds \
					 yggdrasil.o \
					 uart.o \
					 text.o \
					 funkis.o
	riscv64-unknown-elf-ld -T virt.lds \
	  -o yggdrasil \
		yggdrasil.o \
		uart.o \
		text.o \
		funkis.o

clean:
	rm *.o yggdrasil

yggdrasil.o: src/yggdrasil.asm
	riscv64-unknown-elf-as -o yggdrasil.o src/yggdrasil.asm

uart.o: src/uart.asm
	riscv64-unknown-elf-as -o uart.o src/uart.asm

text.o: src/text.asm
	riscv64-unknown-elf-as -o text.o src/text.asm

funkis.o: src/funkis.asm
	riscv64-unknown-elf-as -o funkis.o src/funkis.asm
