00            addi    x3, x0, 0xE
04            sw      x3, (0x20)(x0)  # word 8 in memory
08            lw      x5, (0x20)(x0)
0c            add     x6, x5, x0 
10            beq     X5, x6, 0x8
14            add     x6, x0, x0      # shouldn't happen
18            bne     x5, x6, 0x8
1c            slli    x7, x6, 0x2     # x7 = 0x38
20            lui     x12, 0x400  
24            add     x12, x12, x0    # x12 = 0x400000 (io address)  
28            sw      x3, (0x4)(x12)  # put 0x4 in leds
2c            jal     x1, sub2        # address pc + Jimm
30            andi    x10, x9, 0x36   # x10 = x9
..
..       sub2:
40            addi    x8, x0, 0x2     # x8 = 2
44            sub     x9, x7, x8      # x9 = x8 - 2
48            jalr    x0, x1, 0x0