.section .text

.global _init_heap
.global _get_some

# Constants
.equ TAKEN_FLAG,        0x80000000
# T1SS SSSS - 6 bit
.equ SUPER_SHORT_FLAG,  0x40000000
.equ SUPER_SHORT_MASK,  0x3F000000
.equ SUPER_SHORT_SHIFT, 16 + 8
.equ SUPER_SHORT_MAX,   64-1
.equ SUPER_SHORT_SIZE,  1
# T01S SSSS SSSS SSSS - 13 bit
.equ SHORT_FLAG,        0x20000000
.equ SHORT_MASK,        0x1FFF0000
.equ SHORT_SHIFT,       16
.equ SHORT_MAX,         8192-1
.equ SHORT_SIZE,        2
# T001 SSSS SSSS SSSS SSSS SSSS SSSS SSSS - 28 bit
.equ MASSIVE_FLAG,      0x10000000
.equ MASSIVE_MASK,      0x0FFFFFFF
#.equ MASSIVE_SHIFT,     0
.equ MASSIVE_MAX,       268435456-1
.equ MASSIVE_SIZE,      4

# Not likely to be necessary, but if
# we don't and it is we are possibly
# sort of screwed.
_init_heap:  
  la t0, __heap_start$
  sd zero, 0(t0)
  sd zero, 1(t0)
  ret

# Allocate a segment of memory, atleast the size of the
# requested byte count, but aligned to metadata size.
# a0: Requested byte count.
_get_some:
  addi sp, sp, -40
  sd s0, 0(sp)
  sd s1, 8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)
  sd ra, 32(sp)
  mv s0, a0
  la s1, __heap_start$
find_free_block:
  ld s2, 0(s1) # Load current metadata.
  bnez s2, check_if_block_is_free # We are not at the end of the heap.
  mv a0, s0
  call __allocate_new_block # Create metadata.
  j return_address # Done!
check_if_block_is_free:
  mv a0, s2
  call __get_allocated_size
  mv s3, a0
  mv a0, a1
  call __get_shift_value
  li t0, TAKEN_FLAG
  srl t0, t0, a0
  and t0, t0, s2
  bnez t0, skip_to_next # This block is taken, jump to next block.
  bgt s0, a0, skip_to_next # This block is too small, skip to next.
  or a0, t0, s2 # Taken!
  j return_address
skip_to_next:
  add s1, s1, s3 # Skip block.
  j find_free_block # Try again.
return_address:
  sd a0, 0(s1)  # Store metadata.
  mv a0, s1 # Get pointer address
  add a0, s1, a1 # Move allocation address to a0 and offset.
  ld s0, 0(sp)
  ld s1, 8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  ld ra, 32(sp)
  addi sp, sp, 40
  ret

# a0: Size of metadata
__get_shift_value:
  addi sp, sp, -16
  sd ra, 0(sp)
  sd s0, 8(sp)
  li s0, SUPER_SHORT_SIZE
  bne a0, s0, short_value
  li a0, SUPER_SHORT_SHIFT
  j return_value
short_value:
  li s0, SHORT_SIZE
  bne a0, s0, massive_value
  li a0, SHORT_SHIFT
  j return_value
massive_value:
  li a0, 0
return_value:
  ld ra, 0(sp)
  ld s0, 8(sp)
  addi sp, sp, 16
  ret

# a0: Metadata and possible extras.
__get_allocated_size:
  addi sp, sp, -8
  sd ra, 0(sp)
  li t0, SUPER_SHORT_FLAG
  srli t0, t0, SUPER_SHORT_SHIFT
  and t0, t0, a0
  bnez t0, super_short_block_size
  li t0, SHORT_FLAG
  srli t0, t0, SHORT_SHIFT
  and t0, t0, a0
  bnez t0, short_block_size
  li t0, MASSIVE_FLAG
  and t0, t0, a0
  bnez t0, massive_block_size
  li a0, 0 # No space allocated.
  li a1, 0 # Size not valid.
super_short_block_size:
  li t0, SUPER_SHORT_MASK
  srli t0, t0, SUPER_SHORT_SHIFT
  and a0, a0, t0
  li a1, SUPER_SHORT_SIZE
  j return_size
short_block_size:
  li t0, SHORT_MASK
  srli t0, t0, SHORT_SHIFT
  and a0, a0, t0
  li a1, SHORT_SIZE
  j return_size
massive_block_size:
  li t0, MASSIVE_MASK
  and a0, a0, t0
  li a1, MASSIVE_SIZE
  j return_size
return_size:
  ld ra, 0(sp)
  addi sp, sp, 8
  ret

# a0: Requested byte count.
__allocate_new_block:
  addi sp, sp, -8
  sd ra, 0(sp)
  mv t0, a0
  li a0, SUPER_SHORT_MAX
  li a1, SUPER_SHORT_SIZE
  ble t0, a0, super_short_block
  li a0, SHORT_MAX
  li a1, SHORT_SIZE
  ble t0, a0, short_block
#  li a0, MASSIVE_MAX
  li a1, MASSIVE_SIZE
  mv a0, t0
  add a0, a0, a1 # Pad with metadata size.
  call __align_by
  li t0, MASSIVE_FLAG
  or a0, a0, t0
  li t0, TAKEN_FLAG
  or a0, a0, t0
  j allocate_done
super_short_block:
  mv a0, t0
  add a0, a0, a1 # Pad with metadata size.
  call __align_by
  li t0, SUPER_SHORT_FLAG
  srli t0, t0, SUPER_SHORT_SHIFT
  or a0, a0, t0
  li t0, TAKEN_FLAG
  srli t0, t0, SUPER_SHORT_SHIFT
  or a0, a0, t0
  j allocate_done
short_block:
  mv a0, t0
  add a0, a0, a1 # Pad with metadata size.
  call __align_by
  li t0, SHORT_FLAG
  srli t0, t0, SHORT_SHIFT
  or a0, a0, t0
  li t0, TAKEN_FLAG
  srli t0, t0, SHORT_SHIFT
  or a0, a0, t0
allocate_done:
  ld ra, 0(sp)
  addi sp, sp, 8
  ret

# a0: Value to align.
# a1: Value to align by.
__align_by:
  mv t0, a0
  mv t1, ra
calculate_modulo:
  bgt a0, a1, subtract_more # If a0 is greater or equal to a1, reduce it.
  j modulo_done # a0 is less than a1, so it's the modulo of a1.
subtract_more:
  sub a0, a0, a1 # Reduce a0 by a1.
  j calculate_modulo # Check if we are done.
modulo_done:
  sub a0, a1, a0 # Calculate difference of a0 modulo a1, and a1.
  add a0, t0, a0 # Add the difference to the value to align.
  mv ra, t1
  ret

# Write a register in hex to the UART.
__write_register:
  addi sp, sp, -32 # Make space for s0, s1 and ra.
  sd s0, 0(sp) # Store s0 on stack.
  sd s1, 8(sp) # Store s1 on stack.
  sd ra, 16(sp) # Store ra on stack.
  sd a0, 24(sp) # Store the value.
  li s0, 64 # The number of bits to write.
  mv s1, a0 # The bits we want to write.
write_more:
  addi s0, s0, -4     # We write one hexadecimal (4 bit) character at a time.
  srl a0, s1, s0      # We start with the highest bits we still haven't done.
  andi a0, a0, 0xF    # And we only care about the last four bits.
  call _num_to_hex    # Transform the bits to a hexadecimal character.
  call _write_char    # Print the character to the UART.
  bnez s0, write_more # If we have bits left, we write more.
wrote_register:
  call _newline
  call _write_char
  ld s0, 0(sp) # Restore s0 from stack.
  ld s1, 8(sp) # Restore s1 from stack.
  ld ra, 16(sp) # Restore ra from stack.
  ld a0, 24(sp) # Restore the value.
  addi sp, sp, 32 # Return stack space.
  ret
