
module AluDecoder(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic instr_5, isBranch, isALUreg, isALUimm,
    output logic [3:0] aluControl,
    output logic isShamt
);

    always_comb begin
        case({isBranch, isALUreg || isALUimm, funct3})
            5'b01000: aluControl <= (funct7[5] & instr_5) ? (4'h1) : (4'h0);
            5'b01001: aluControl <= 4'h2;
            5'b01010: aluControl <= 4'h3;
            5'b01011: aluControl <= 4'h4;
            5'b01100: aluControl <= 4'h5;
            5'b01101: aluControl <= funct7[5]? 4'h6 : 4'h7; 
            5'b01110: aluControl <= 4'h8;
            5'b01111: aluControl <= 4'h9;
            5'b10000: aluControl <= 4'ha;
            5'b10001: aluControl <= 4'hb;
            5'b10100: aluControl <= 4'h3;
            5'b10101: aluControl <= 4'hc;
            5'b10110: aluControl <= 4'h4;
            5'b10111: aluControl <= 4'hd;
            default: aluControl <= 4'h0;  // adder by default
        endcase
        case({isALUreg || isALUimm, funct3})
            4'b1001, 4'b1101: isShamt <= 1'b1;
            default: isShamt <= 1'b0;
        endcase
    end
endmodule
