# Test program

.equ IO_BASE, 0x400000  
.equ IO_LEDS, 4

.section .text

.globl start

start:
    li      gp, IO_BASE
    li      sp, 0x0200
    addi    t0, zero, 0xE           # t0 = 14
    sw      t0, (0x20)(zero)        # word 8 in memory
    lw      t1, (0x20)(zero)
    add     t2, t1, zero 
    beq     t1, t2, continue
    add     t2, zero, zero          # shouldn't happen

continue:
    bne     t1, t2, dont
    slli    t3, t2, 0x2             # t3 = 56
    
dont:
    sw      t0, IO_LEDS(gp)
    jal     sub2                    # address pc + Jimm
    andi    t5, s2, 0x36            # t5 = 54 & 54

freeze:
    nop
    j freeze

sub2:
    addi    t6, zero, 0x2           # t6 = 2
    sub     s2, t3, t6              # s2 = 56 - 2
    ret
