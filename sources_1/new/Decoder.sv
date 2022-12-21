`timescale 1ns / 1ps

module Decoder(
    input logic [31:0] inst,
    output logic isALUreg, regWrite
);

    localparam len = 6;

    logic isALUreg =  (instr[len:0] == 7'b0110011); // rd <- rs1 OP rs2   
    logic isALUimm =  (instr[len:0] == 7'b0010011); // rd <- rs1 OP Iimm
    logic isBranch =  (instr[len:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
    logic isJALR   =  (instr[len:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
    logic isJAL    =  (instr[len:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
    logic isAUIPC  =  (instr[len:0] == 7'b0010111); // rd <- PC + Uimm
    logic isLUI    =  (instr[len:0] == 7'b0110111); // rd <- Uimm   
    logic isLoad   =  (instr[len:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
    logic isStore  =  (instr[len:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
    logic isSYSTEM =  (instr[len:0] == 7'b1110011); // special

    assign regWrite = isALUreg || isALUimm || isLoad || isLUI || isAUIPC || isJAL || isJALR;

endmodule
