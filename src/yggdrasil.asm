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

  call _newline
  call _write_char

  la a0, heart
  li a1, 16
  call write_memory_bytes

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
  addi sp, sp, -24 # Make space for s0, s1 and ra.
  sd s0, 0(sp) # Store s0 on stack.
  sd s1, 8(sp) # Store s1 on stack.
  sd ra, 16(sp) # Store ra on stack.
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
  ld s0, 0(sp) # Restore s0 from stack.
  ld s1, 8(sp) # Restore s1 from stack.
  ld ra, 16(sp) # Restore ra from stack.
  addi sp, sp, 24 # Return stack space.
  ret

# Write a memory segment to the UART.
write_memory_bytes:
  addi sp, sp, -32 # Reserve stack space.
  sd s0, 0(sp)
  sd s1, 8(sp)
  sd s2, 16(sp)
  sd ra, 24(sp)
  mv s0, a0
  mv s1, a1
write_bytes:
  beq s1, zero, wrote_bytes
  mv a0, s0
  call write_register
  li a0, 0x20
  call _write_char
  lb a0, 0(s0)
  andi s2, a0, 0x0F # Save the four lower bits.
  andi a0, a0, 0xF0 # Save the four upper bits.
  srli a0, a0, 4    # Shift them right, to lower.
  call _num_to_hex # Hexify upper four bits.
  call _write_char # Write hex digit.
  mv a0, s2 # Fetch the lower bits.
  call _num_to_hex # Hexify lower four bits.
  call _write_char # Write hex digit.
  li a0, 0x0A
  call _write_char
  addi s1, s1, -1
  addi s0, s0, 1
  j write_bytes
wrote_bytes:
  ld s0, 0(sp)
  ld s1, 8(sp)
  ld s2, 16(sp)
  ld ra, 24(sp)
  addi sp, sp, 32 # Restore stack space.
  ret