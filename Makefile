all: yggdrasil

clean:
	rm *.o yggdrasil

yggdrasil: virt.lds \
					 yggdrasil.o \
					 uart.o \
					 text.o \
					 funkis.o \
					 memories.o
	riscv64-unknown-elf-ld -verbose -T virt.lds \
	  -o yggdrasil \
		yggdrasil.o \
		uart.o \
		text.o \
		funkis.o \
		memories.o

.SUFFIXES: .o .asm

%.o: src/%.asm
	riscv64-unknown-elf-as -verbose $< -o $@
