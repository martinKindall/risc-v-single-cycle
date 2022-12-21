
module AluDecoder(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic instr_5,
    output logic [3:0] aluControl,
    output logic isShamt
);

    always_comb begin
        case(funct3)
            3'b000: aluControl <= (funct7[5] & instr_5) ? (4'h1) : (4'h0);
            3'b001: aluControl <= 4'h2;
            3'b010: aluControl <= 4'h3;
            3'b011: aluControl <= 4'h4;
            3'b100: aluControl <= 4'h5;
            3'b101: aluControl <= funct7[5]? 4'h6 : 4'h7; 
            3'b110: aluControl <= 4'h8;
            3'b111: aluControl <= 4'h9;
        endcase
        case(funct3)
            3'b001: 
            3'b101: isShamt <= 1'b1;
            default: isShamt <= 1'b0;
        endcase
    end

endmodule
