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

  la a0, yggdrasil
  call _write_str
  call _newline
  call _write_char

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
  beq t1, t1, hold

