
module Alu(
    input logic [3:0] aluControl,
    input logic [31:0] op1, op2,
    output logic [31:0] aluOut,
    output logic isZero
);

    always_comb 
        case (aluControl)
            4'h0: aluOut <= op1 + op2;
            4'h1: aluOut <= op1 - op2;
            4'h2: aluOut <= op1 << op2;
            4'h3: aluOut <= $signed(op1) < $signed(op2);
            4'h4: aluOut <= op1 < op2;
            4'h5: aluOut <= op1 ^ op2;
            4'h6: aluOut <= $signed(op1) >>> op2;
            4'h7: aluOut <= op1 >> op2;
            4'h8: aluOut <= op1 | op2;
            4'h9: aluOut <= op1 & op2;
            default: aluOut <= 31'b0;
        endcase

    assign isZero = ~|aluOut;        

endmodule
