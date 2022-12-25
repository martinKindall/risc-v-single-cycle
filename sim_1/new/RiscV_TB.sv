`timescale 1ns / 1ps

module RiscV_TB;

    logic clk, reset;
    logic [31:0] instr, memWdata, addr, pc, aluIn1, aluIn2, Simm, Jimm, memRdata;
    logic [4:0] rs1Id, rs2Id, rdId, leds;
    logic [3:0] memWMask;
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

    RiscV dut(
        clk, reset,
        pc, instr, memWdata, addr, 
        aluIn1, 
        aluIn2,
        Simm,
        Jimm,
        memRdata,
        rs1Id, rs2Id, rdId,
        memWMask,
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

    initial begin
        reset = 1; #15; 
        reset = 0; #2;
    end

    always begin
        clk <= 1; #5;     
        clk <= 0; #5;     
    end

    always @(negedge clk) begin
        if (rdId == 4'ha && addr == 8'h36) begin
            $finish;
        end
    end

endmodule