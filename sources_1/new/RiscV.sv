`timescale 1ns / 1ps
 
module RiscV(
    input logic clk, reset,
    input logic [15:0] keyboard_data,
    input logic [7:0] r_data_vga_cpu,
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
    output logic [4:0] leds,
    output logic [15:0] short_segments,
    output logic [11:0] char_write_read_addr,
    output logic [7:0] char_write_data,
    output logic char_write_enable,
    output logic char_read_enable,
    output logic keyboard_clear_on_read
);

    logic isALUreg, regWrite, isZero, isIO, isRAM;

    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [31:0] memRdataLogic;

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
        memRdataLogic,
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

    IMemory imem(pc[13:2], instr);
    DMemory dmem(
        clk, 
        {{4{isStore & isRAM}} & memWMask},
        addr,
        memWdata,
        memRdata
    );

    IODriver io(
        clk,
        reset,
        isIO,
        isStore,
        isLoad,
        addr,
        memWdata,
        memRdata,
        keyboard_data,
        r_data_vga_cpu,
        leds,
        short_segments,
        char_write_read_addr,
        char_write_data,
        char_write_enable,
        char_read_enable,
        keyboard_clear_on_read,
        memRdataLogic
    );

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    assign isIO = addr[22];
    assign isRAM = !isIO;

endmodule
