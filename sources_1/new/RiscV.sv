`timescale 1ns / 1ps
 
module RiscV(
    input logic clk, reset,
    output logic [31:0] pc, instr, memWdata, addr, aluIn1, aluIn2, Simm,
    output logic [4:0] rs1Id, rs2Id, rdId,
    output logic isALUreg, 
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

    logic isALUreg, regWrite, isZero;

    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [3:0] memWMask, aluControl;
    logic [31:0] memRdata;

    Decoder decoder(
        instr,
        isALUreg, 
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI,
        isAUIPC,
        isALUimm,
        isLoad, 
        isStore
    );

    AluDecoder aluD(
        funct3,
        funct7,
        instr[5],
        isBranch,
        isALUreg,
        isALUimm,
        aluControl,
        isShamt
    );

    Datapath dpath(
        clk, 
        reset,
        isALUreg,
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI, 
        isAUIPC,
        isLoad,
        isStore,
        isShamt,
        funct3,
        aluControl,
        instr,
        memRdata,
        pc,
        addr,
        memWdata,
        aluIn1, 
        aluIn2,
        Simm,
        rs1Id, rs2Id, rdId,
        memWMask,
        isZero
    );

    IMemory imem(pc[9:2], instr);
    DMemory dmem(
        clk, 
        memWMask,
        addr,
        memWdata,
        memRdata
    );

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

endmodule
