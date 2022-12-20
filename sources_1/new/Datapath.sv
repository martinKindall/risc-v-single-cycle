
module Datapath(
    input logic clk, reset,
    input logic [x:0] alucontrol,
    input logic [31:0] instr,
    output logic [31:0] pc, aluOut,
    output logic isZero
);

    logic [4:0] rs1Id = instr[19:15];
    logic [4:0] rs2Id = instr[24:20];
    logic [4:0] rdId  = instr[11:7];

    logic [2:0] funct3 = instr[14:12];
    logic [6:0] funct7 = instr[31:25];

    logic [31:0] Uimm = {    instr[31],   instr[30:12], {12{1'b0}}};
    logic [31:0] Iimm = {{21{instr[31]}}, instr[30:20]};
    logic [31:0] Simm = {{21{instr[31]}}, instr[30:25],instr[11:7]};
    logic [31:0] Bimm = {{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
    logic [31:0] Jimm = {{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};


endmodule
