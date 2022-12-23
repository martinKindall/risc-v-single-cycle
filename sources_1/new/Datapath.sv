
module Datapath(
    input logic clk, reset,
    input logic isALUreg, regWrite, isJAL, isJALR, isBranch, isLUI, isAUIPC,
    input logic [3:0] aluControl,
    input logic [31:0] instr,
    output logic [31:0] pc, aluOut,
    output logic isZero
);
    logic [31:0] pcNext, pcplus4, pcplusImm, aluIn1, aluIn2, aluIn2Pre, rd1, rd2, wd3;

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

    logic [4:0] shamt = isALUreg ? rd2[4:0] : instr[24:20];

    FlopR pcreg(clk, reset, pcNext, pc);
    Adder pcadd1(pc, 32'b100, pcplus4);
    // mux here? to select either PC or JUMP
    // also compute the BRANCH and JUMP addresses, TODO (see how is it done in the guide first)

    RegisterFile reg(clk, regWrite, rs1Id, rs2Id, rdId, wd3, rd1, rd2);

    Alu alu(aluControl, aluIn1, aluIn2, aluOut, isZero);

    assign pcplusImm = pc + (instr[3] ? Jimm[31:0] :
                             instr[4] ? Uimm[31:0] :
                             Bimm[31:0]);

    assign aluIn1 = rd1;
    assign aluIn2Pre = (isALUreg | isBranch) ? rd2 : 
                       Iimm;
    assign aluIn2 = isShamt ? shamt : aluIn2Pre;

    assign pcNext = (isBranch && ~isZero || isJAL) ? pcplusImm :
                    isJALR ? {aluOut[31:1],1'b0}:
                    pcplus4;

    assign wd3 = (isJAL || isJALR) ? pcplus4 :
                 isLUI ? Uimm :
                 isAUIPC ? pcplusImm : 
                 aluOut;

endmodule
