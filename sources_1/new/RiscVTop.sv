`timescale 1ns / 1ps

module RiscVTop(
   input logic clk, reset, clkEnable,
   output logic [6:0] led_segment,
   output logic [3:0] anode_activate,
   output logic [4:0] leds,
   output logic slow_clk, dp     
);

    logic [31:0] pc, instr, memWdata, addr, aluIn1, aluIn2, Simm, Jimm, Bimm, Iimm, memRdata;
    logic [4:0] rs1Id, rs2Id, rdId;
    logic [3:0] memWMask, aluControl;
    logic isALUreg, 
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI,
        isAUIPC,
        isALUimm,
        isLoad, 
        isStore,
        isShamt;

    logic [15:0] displayed_number;

    SlowClock slowClock(clk, clkEnable, slow_clk);

    SevenSegmentTop sevenSegmentTop(
        .clk(clk),
        .displayed_number(displayed_number),
        .led_segment(led_segment),
        .anode_activate(anode_activate),
        .dp(dp));

    RiscV riscv(slow_clk, reset, pc, instr, memWdata, addr, aluIn1, aluIn2, Simm, Jimm, Bimm, Iimm, memRdata, rs1Id, rs2Id, rdId, memWMask, aluControl,
        isALUreg, 
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI,
        isAUIPC,
        isALUimm,
        isLoad, 
        isStore,
        isShamt,
        leds
    );

    assign displayed_number = addr[15:0];

endmodule
