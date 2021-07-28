.section .text

.global _write_char
.global _write_str
.global _read

.equ UART, 0x10000000

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
