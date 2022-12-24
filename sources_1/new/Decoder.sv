`timescale 1ns / 1ps

module Decoder(
    input logic [31:0] instr,
    output logic isALUreg, regWrite, isJAL, isJALR, isBranch, isLUI, isAUIPC, isALUimm,
    output logic isLoad, isStore
);

    localparam len = 6;

    assign isALUreg =  (instr[len:0] == 7'b0110011); // rd <- rs1 OP rs2   
    assign isALUimm =  (instr[len:0] == 7'b0010011); // rd <- rs1 OP Iimm
    assign isBranch =  (instr[len:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
    assign isJALR   =  (instr[len:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
    assign isJAL    =  (instr[len:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
    assign isAUIPC  =  (instr[len:0] == 7'b0010111); // rd <- PC + Uimm
    assign isLUI    =  (instr[len:0] == 7'b0110111); // rd <- Uimm   
    assign isLoad   =  (instr[len:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
    assign isStore  =  (instr[len:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
    assign isSYSTEM =  (instr[len:0] == 7'b1110011); // special

    assign regWrite = isALUreg || isALUimm || isLoad || isLUI || isAUIPC || isJAL || isJALR;

endmodule
