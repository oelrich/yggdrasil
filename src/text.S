
.section .text

.global _num_to_hex
.global _newline

.equ NEW_LINE, 0xa

_num_to_hex:
  li t0, 0xa
  blt a0, t0, hex_print_num
  addi a0, a0, 0x7 # this should bump us up to alpha
hex_print_num:
  addi a0, a0, 0x30
  ret



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

_newline:
  li a0,NEW_LINE
  ret

