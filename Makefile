clean:
	rm uart.o yggdrasil.o yggdrasil

uart.o: src/uart.asm
	riscv64-unknown-elf-as -o uart.o src/uart.asm

yggdrasil.o: src/yggdrasil.asm
	riscv64-unknown-elf-as -o yggdrasil.o src/yggdrasil.asm

yggdrasil: uart.o yggdrasil.o src/virt.lds
	riscv64-unknown-elf-ld -T src/virt.lds -o yggdrasil yggdrasil.o uart.o
