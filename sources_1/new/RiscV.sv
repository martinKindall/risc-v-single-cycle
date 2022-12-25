`timescale 1ns / 1ps
 
module RiscV(
    input logic clk, reset,
    output logic [31:0] pc, instr, memWdata, addr, aluIn1, aluIn2, Simm, Jimm, Bimm, Iimm, memRdata,
    output logic [4:0] rs1Id, rs2Id, rdId,
    output logic [3:0] memWMask, aluControl,
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
        isShamt,
    output logic [4:0] leds
);

    logic isALUreg, regWrite, isZero, isIO, isRAM;

    logic [2:0] funct3;
    logic [6:0] funct7;

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
        Jimm,
        Bimm, Iimm,
        rs1Id, rs2Id, rdId,
        memWMask,
        isZero
    );

    IMemory imem(pc[9:2], instr);
    DMemory dmem(
        clk, 
        {{4{isRAM}} & memWMask},
        addr,
        memWdata,
        memRdata
    );

    IODriver io(clk, addr, memWdata, isIO, leds);

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    assign isRAM = !isIO;

endmodule
