`timescale 1ns / 1ps

module RiscV(
    input logic clk, reset,
    output logic 
);

    logic isALUreg, regWrite, 
        isJAL, isJALR, isBranch,
        isLUI, isAUIPC, isLoad, 
        isStore, isZero, isShamt,
        isALUimm;

    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [3:0] memWMask, aluControl;
    logic [31:0] pc, instr, addr, memWdata, memRdata;

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
        aluControl,
        instr,
        memRdata,
        pc,
        addr,
        memWdata,
        memWMask,
        isZero
    );

    IMemory imem(pc, instr);
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
