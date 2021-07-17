.section .text

.global _get_some

.equ MEM_START, 0x80000000
.equ MEM_LENGTH,0x08000000 # 128 MB

# a0: byte count
_get_some:
