.section .rodata
#hello:
#  .string "Hello World!\n"
#hello_len:
#  .word 0xd
heart:
  .string "❤️"
heart_len:
  .word 0x3
yggdrasil:
  .string "🌳"
yggdrasil_len:
  .word 0x4
.section .data
yggdrasil_lock:
  .word 0x0

.section .text
.global _start

_start:
  la t0, yggdrasil_lock
  li t1, 1
try_lock:
  amoswap.w.aq t1, t1, (t0)
  bnez t1, try_lock
  lw a0, heart_len
  la a1, heart
  call _write # This bugs out on occasion ...
  csrr s0, mhartid
  mv a0, s0
  call _num_to_hex
  call _write_char
  call _newline
  call _write_char
  la t0, yggdrasil_lock
  amoswap.w.rl zero, zero, (t0)
  beq s0, zero, no_sleep
  wfi
no_sleep:
  call _newline
  call _write_char
  lw a0, yggdrasil_len
  la a1, yggdrasil
  call _write
  call _newline
  call _write_char
  
  #csrr a0, mhartid
  #jal hex_print
  call _terminate

hold:
  beq t1, t1, hold

