.section .text

.global _init_heap
# .global _get_some

# # allocatable memory starts at __heap_start$
# # bits [max allocate]
# #   f: [01] free/allocated
# #   x0...xn: bytes till next block 
# # f1xx xxxx (byte)
# #  6 + 0x8 ->        64
# # f01x xxxx xxxx xxxx (2 byte)
# #  5 + 1x8 ->     8 192
# # f001 xxxx xxxx xxxx xxxx xxxx xxxx xxxx (4 byte)
# #  4 + 3x8 -> 268 435 456 (256 MB)
# # f000 yyyy  (2^4 * 64 bit)
# get_metadata_byte_count:
#   addi t1, zero, 0x1
#   slli t1, t1, 63 # Free bit.
#   not t2, t1 # Mask all but free bit.
#   and t0, t2, a0 # Save metadata without free bit.
#   li a0, 1 # Set minimum no. bytes.
#   srli t1, t1, 1 # super short
#   and t2, t1, t0
#   bnez t2, super_short
#   srli t1, t1, 1  # shortish
#   and t2, t1, t0
#   bnez t2, shortish
#   addi a0, 2
# shortish:
#   addi a0, 1
# super_short:
#   ret

# # a0, metadata size
# # a1, metadata
# get_metadata_allocation_size:
#   li t1, 0x1
#   slli t1, t1, 63
#   sra t1, t1, 1 # covers super short
#   li t0, 1
#   beq a0, t0, invert_it
#   sra t1, t1, 1 # covers short
#   li t0, 2
#   beq a0, t0, invert_it
#   sra t1, t1, 1 # covers massive  
#   # super short: 0011 1111
#   # short: 0001 1111 1111 1111
#   # massive: 0000 1111 1111 1111 1111 1111 1111 1111
# invert_it:
#   not t1, t1 # Now we have the mask.
#   and a0, a0, t1 # And now the metadata only contains size info.
#   sub t0, 4, a0 # Figure out how many bytes to shift.
#   mul t0, t0, 8 # Make them bits.
#   srl a0, a1, t0 # Move the bits to the correct place.
#   ret

# is_metadata_allocated:
#   mv a1, a0
#   li t0, 0x80
#   slli t0, t0, 56
#   and a0, a0, t0
#   ret

# # Set the topmost bit of a0.
# set_metadata_allocated:
#   li t0, 0x80
#   slli t0, t0, 56
#   or a0, a0, t0
#   ret

# # Unset the topmost bit of a0.
# set_metadata_free:
#   li t0, 0x80
#   slli t0, t0, 56
#   not t0, t0
#   and a0, a0, t0
#   ret

# load_metadata:
#   mv t5, a0
#   addi t0, zero, 0x1
#   slli t1, t0, 63 # free/allocated bit
#   and a0, t5, t1 # Set a0 to the value of free
#   srli t2, t1, 1  # super short
#   and t0, t5, t2
#   bnez t0, super_short
#   srli t3, t2, 1  # shortish
#   and t0, t5, t3
#   bnez t0, shortish
#   srli t4, t3, 1  # massive
#   and t0, t5, t4
#   bnez t0, massive
#   # We could not find a valid size.
#   # Either we are at the end of the heap
#   # or something has broken down.
#   mv a0, zero
#   mv a1, zero
# finish:
#   ret
# massive: # f001 xxxx xxxxxxxx xxxxxxxx xxxxxxxx
#   addi t0, zero, 0xFFFFFF
#   slli t0, t0, 16
#   addi t0, t0, 0xFFFFFFFF
#   srli a1, t5, 32
#   and a1, a1, t0
#   j finish
# super_short: # f1xx xxxx
#   addi t0, zero, 0x3F
#   srli a1, t5, 32 + 16 + 8
#   and a1, a1, t0
#   j finish
# shortish: # f01x xxxx xxxx xxxx
#   addi t0, zero, 0x3F
#   slli t0, t0, 62 # free/allocated bit
#   and a1, a1, t0
#   j finish

# get_allocation_block_offset:
#   mv t5, a0
#   addi t0, zero, 0x1
#   slli t1, t0, 63 # free/allocated bit
#   srli t2, t1, 1  # super short
#   and t0, t5, t2
#   bnez t0, super_short
#   srli t3, t2, 1  # shortish
#   and t0, t5, t3
#   bnez t0, shortish
#   srli t4, t3, 1  # massive
#   and t0, t5, t4
#   bnez t0, massive
#   # We could not find a valid size.
#   # Either we are at the end of the heap
#   # or something has broken down.
#   addi a0, a0, 1
# finish:
#   ret
# massive: # f001 xxxx xxxxxxxx xxxxxxxx xxxxxxxx
#   addi t0, zero, 0xFFFFFF
#   slli t0, t0, 16
#   addi t0, t0, 0xFFFFFFFF
#   srli a0, t5, 32
#   and a0, a0, t0
#   addi a0, a0, 4 # the four bytes our metadata takes
#   j finish
# super_short: # f1xx xxxx
#   addi t0, zero, 0x3F
#   srli a0, t5, 32 + 16 + 8
#   and a0, a0, t0
#   addi a0, a0, 1 # one byte of metadata
#   j finish
# shortish: # f01x xxxx xxxx xxxx
#   addi t0, zero, 0x3F
#   slli t0, t0, 62 # free/allocated bit
#   and a0, a0, t0
#   addi a0, a0, 2 # two bytes of metadata
#   j finish


# allocate_existing:
#   mv t5, a0 # base address
#   addi t0, zero, 0x1
#   slli t1, t0, 63 # free/allocated bit
#   and a0, t5, t1 # Set a0 to the value of free
#   srli t2, t1, 1  # super short
#   and t0, t5, t2
#   bnez t0, super_short
#   srli t3, t2, 1  # shortish
#   and t0, t5, t3
#   bnez t0, shortish
#   srli t4, t3, 1  # massive
#   and t0, t5, t4
#   bnez t0, massive
#   # We could not find a valid size.
#   # Either we are at the end of the heap
#   # or something has broken down.
#   mv a0, zero
#   mv a1, zero
# finish:
#   ret
# massive: # f001 xxxx xxxxxxxx xxxxxxxx xxxxxxxx
#   addi a0, t5, 4
#   j finish
# super_short: # f1xx xxxx
#   addi a0, t5, 1
#   j finish
# shortish: # f01x xxxx xxxx xxxx
#   addi a0, t5, 2
#   j finish

# get_allocation_address_offset:
#   li a0, 4
#   ret

# Not likely to be necessary, but if
# we don't and it is we are possibly
# sort of screwed.
_init_heap:  
  la t0, __heap_start$
  sd zero, 0(t0)
  sd zero, 1(t0)
  ret

# # a0: Requested byte count.
# _get_some:
#   mv s0, ra # Save return address.
#   mv s1, a0 # Save the desired number of bytes.
#   la s2, __heap_start$ # Start at the beginning of the heap.
# check_block:
#   ld s3, s2 # Load metadata.
#   mv a0, s3 # Store a copy so we don't need to hit RAM so often.
#   call is_metadata_allocated
#   bnez a0, skip_to_next
#   mv a0, s3 # Copy metadata to a0.
#   call get_metadata_byte_count # Store bytes for metadata in a0.
#   mv a1, s3 # Copy metadata to a1.
#   call get_metadata_allocation_size # Get allocated byte count for block.
#   ble s1, a0, allocate_existing # The block is large enough.
#   bnez a0, skip_to_next # The block is too small.
#   mv a0, s2 # Address.
#   mv a1, s1 # Desired byte count.
#   call create_metadata
#   j done
# allocate_existing:
#   mv a0, s3 # The metadata.
#   call set_metadata_allocated
#   j done
# skip_to_next:
#   mv a0, s2
#   call get_allocation_block_offset
#   add s2, s2, a0
#   j check_block
# done:
#   sd a0, 0(s2) # Store the update metadata.
#   call get_allocation_address_offset
#   add a0, a0, s2 # Get the user addressable data.
#   mv ra, s0
#   ret