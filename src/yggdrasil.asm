.section .rodata
hello:
  .string "Hello World!\n"
hello_len:
  .word 0xd
heart:
  .string "❤️"
heart_len:
  .word 0x3
yggdrasil:
  .string "🌳"
yggdrasil_len:
  .word 0x4
yes:
  .string "yes"
no:
  .string "no"

.section .text
.global _start

_start:
  csrr t0, mhartid
  beq t0, zero, no_sleep
  wfi
no_sleep:  
  lw a0, yggdrasil_len
  la a1, yggdrasil
  call _write
  call _newline

  lw a0, heart_len
  la a1, heart
  call _write
  
  csrr a0, mhartid
  jal hex_print
  call _newline

  addi t5, zero, 15
  addi a0, zero, 0
hexen_stepper:
  #jal hex_print
  addi a0, a0, 1
  bne a0, t5, hexen_stepper
 # jal hex_print
  call _newline

  lw a0, hello_len
  la a1, hello
  call _write

#  addi a0, zero, 0
#  addi a1, zero, 0
#  addi t5, zero, 113 # End on 'q'
#ready:
#  call _read
#  mv a1, a0
#  beq a1, zero, ready
#  addi a0, zero, 1
#  call _write
#  beq a1, t5, ready_done
#  j ready
#ready_done:

  j terminate

hold:
  beq t1, t1, hold

terminate:
  li t0, 0x100000 # VIRT_TEST
  li t1, 0x5555   # SHUTDOWN
  sw t1, 0(t0)

hex_print:
  addi t0, zero, 0xa
  addi t1, a0, 0x30
  blt a0, t0, hex_print_num
  addi t1, t1, 0x7 # this should bump us up to alpha
  mv a1, t1
hex_print_num:
  mv t5, ra
  addi a0, zero, 1
  call _write
  mv ra, t5
  ret


