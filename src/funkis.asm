.section .text
.global _terminate

_terminate:
  li t0, 0x100000 # VIRT_TEST
  li t1, 0x5555   # SHUTDOWN
  sw t1, 0(t0)
