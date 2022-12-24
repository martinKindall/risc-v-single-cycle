`timescale 1ns / 1ps

module RiscV_TB;

    logic clk, reset;
    logic [31:0] instr, memWdata, addr, pc, aluIn1, aluIn2, Simm;
    logic [4:0] rs1Id, rs2Id, rdId;
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
        rs1Id, rs2Id, rdId,
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
        isShamt
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
        if (isStore) begin
            $finish;
        end
    end

endmodule
