.section .rodata
# Here are some constant strings.
# They start by giving the length,
# in bytes, and then the bytes.
heart:
  .word 0x6
  .string "❤️"
spock:
  .word 0x4
  .string "🖖"
yggdrasil:
  .word 0x4
  .string "🌳"

.section .bss
yggdrasil_lock:
  .word 0x0
yggdrasil_sleepers:
  .word 0x0

.section .text
.global _start

_start:
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, __stack_pointer$
  la t0, yggdrasil_lock
  li t1, 1
try_lock:
  amoswap.w.aq t1, t1, (t0)
  bnez t1, try_lock  
  la a0, heart
  fence iorw,iorw
  call _write_str # This bugs out on occasion ...
  csrr s0, mhartid
  mv a0, s0
  fence iorw,iorw
  call _num_to_hex
  fence iorw,iorw
  call _write_char
  fence iorw,iorw
  call _newline
  call _write_char
  # the hart id is written
  # count our precense and
  # possibly sleep
  la t1, yggdrasil_sleepers
  lw t2, 0(t1)
  addi t2, t2, 1
  sw t2,0(t1) 
  la t0, yggdrasil_lock
  amoswap.w.rl zero, zero, (t0)
  beq s0, zero, no_sleep
  wfi
no_sleep:
  # we are the woke hart,
  # check if the rest are
  # fast asleep and we can
  # do our work
  la t1, yggdrasil_sleepers
  lw t2, 0(t1)
  li t3, 4
  bne t2, t3, no_sleep
  call _newline
  call _write_char

  call _init_heap

  la a0, yggdrasil
  call _write_str
  call _newline
  call _write_char
  call _newline
  call _write_char

  # Write global pointer
  mv a0, gp
  call write_register
  call _newline
  call _write_char

  # Write stack pointer
  mv a0, sp
  call write_register
  call _newline
  call _write_char
  
  # Write start of heap.
  la a0, __heap_start$
  call write_register
  call _newline
  call _write_char

  # Write entry in start of heap
  la t1, __heap_start$
  ld a0, 0(t1)
  call write_register
  call _newline
  call _write_char
  
  addi a0, zero, 0x1
  slli a0, a0, 63
  call write_register
  call _newline
  call _write_char

  addi a0, zero, 0x1
  slli a0, a0, 63
  srli a0, a0, 1
  call write_register
  call _newline
  call _write_char
  
# Clear and write
# Vulcan Greeting
# before exiting.
  call _newline
  call _write_char

  la a0, spock
  call _write_str
  call _newline
  call _write_char
  
  #csrr a0, mhartid
  #jal hex_print
  call _terminate

hold:
  nop
  j hold

# Write a register in hex to the UART.
write_register:
  li s0, 64 # The number of bits to write.
  mv s1, a0 # The bits we want to write.
  mv s2, ra # The address we came from.
write_more:
  addi s0, s0, -4     # We write one hexadecimal (4 bit) character at a time.
  srl a0, s1, s0      # We start with the highest bits we still haven't done.
  andi a0, a0, 0xF    # And we only care about the last four bits.
  call _num_to_hex    # Transform the bits to a hexadecimal character.
  call _write_char    # Print the character to the UART.
  bnez s0, write_more # If we have bits left, we write more.
wrote_register:
  mv ra, s2 # Restore the address we came from.
  ret
