addi    x1, x0, 0xE
sw      x1, (0x20)(x0)  # word 8 in memory
lw      x5, (0x20)(x0)
add     x6, x5, x0 
