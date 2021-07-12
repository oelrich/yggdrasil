.section .text

.global _write
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

# length in bytes (a0)
# unicode bytes start (a1)
_write:
#  sw t0, 0(sp)
#  sw t1, 1(sp)
#  sw a0, 2(sp)
#  sw a1, 3(sp)
  li t0, UART
writing_data:
  beq a0, zero, writing_data_done
  lw t1, 0(a1)
  sw t1, 0(t0)
  addi a1, a1, 1
  addi a0, a0, -1
  j writing_data
writing_data_done:
#  lw t0, 0(sp)
#  lw t1, 1(sp)
#  lw a0, 2(sp)
#  lw a1, 3(sp)
  ret
