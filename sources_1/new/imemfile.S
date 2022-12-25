00            addi    x1, x0, 0xE
04            sw      x1, (0x20)(x0)  # word 8 in memory
08            lw      x5, (0x20)(x0)
0c            add     x6, x5, x0 
10            beq     X5, x6, 0x8
14            add     x6, x0, x0      # shouldn't happen
18            bne     x5, x6, 0x8
1c            slli    x7, x6, 0x2     # x7 = 0h38
20            jal     x1, sub2        # address 0h34 = pc + Jimm
24            andi    x10, x9, 0x36   # x10 = x9
..
..       sub2:
34            addi    x8, x0, 0x2     # x8 = 2
38            sub     x9, x7, x8      # x9 = x8 - 2
3c            jalr    x0, x1, 0x0