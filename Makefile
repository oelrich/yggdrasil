AS=riscv64-unknown-elf-as -g
clean:
	rm funkis.o uart.o yggdrasil.o yggdrasil

funkis.o: src/funkis.asm
	${AS} -o funkis.o src/funkis.asm

text.o: src/text.asm
	${AS} -o text.o src/text.asm

uart.o: src/uart.asm
	${AS} -o uart.o src/uart.asm

yggdrasil.o: src/yggdrasil.asm
	${AS} -o yggdrasil.o src/yggdrasil.asm

yggdrasil: funkis.o text.o uart.o yggdrasil.o src/virt.lds
	riscv64-unknown-elf-ld -T src/virt.lds -o yggdrasil yggdrasil.o uart.o text.o funkis.o
