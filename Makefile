all: yggdrasil

yggdrasil: virt.lds \
					 yggdrasil.o \
					 uart.o \
					 text.o \
					 funkis.o \
					 memories.o
	riscv64-unknown-elf-ld -T virt.lds \
	  -o yggdrasil \
		yggdrasil.o \
		uart.o \
		text.o \
		funkis.o \
		memories.o

clean:
	rm *.o yggdrasil

.SUFFIXES: .o .asm

%.o: src/%.asm
	riscv64-unknown-elf-as $< -o $@
