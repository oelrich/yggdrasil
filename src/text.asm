
.section .text

.global _newline

.equ NEW_LINE, 0xa

_newline:
  addi a0,zero,NEW_LINE
  ret