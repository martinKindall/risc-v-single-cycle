addi    x1, x0, 0xE
sw      x1, (0x20)(x0)  # word 8 in memory
lw      x5, (0x20)(x0)
add     x6, x5, x0 
beq     X5, x6, 0x8
add     x6, x0, x0      # shouldn't happen
bne     x5, x6, 0x8
slli    x7, x6, 0x2