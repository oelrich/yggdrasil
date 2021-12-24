.section .text

.global _progress
.global _write_char
.global _write_str
.global _read

.equ UART, 0x10000000

_progress:
  addi sp, sp, -16
  sd s0, 0(sp)
  sd s1, 8(sp)
  li s0, UART
  li s1, 0x2B
  sw s1, 0(s0)
  ld s0, 0(sp)
  ld s1, 8(sp)
  addi sp, sp, 16
  ret


_read:
  addi a0, zero,0x0
  li t0, UART
  lw t1, 5(t0)
  beq t1, zero, read_done
  lw a0, 0(t0)
read_done:
  ret

_write_char:
  li t0, UART
  sw a0, 0(t0)
  ret

# length in bytes address 0(a0)
# unicode bytes start     4(a0)
_write_str:
  lw t1, 0(a0)
  addi t2, a0, 4
  li t0, UART
writing_data:
  beq t1, zero, writing_data_done
  lw t3, 0(t2)
  sw t3, 0(t0)
  addi t2, t2, 1
  addi t1, t1, -1
  j writing_data
writing_data_done:
  ret
