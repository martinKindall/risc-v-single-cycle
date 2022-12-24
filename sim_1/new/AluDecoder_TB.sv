`timescale 1ns / 1ps

module AluDecoder_TB;

    logic clk;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic instr_5, isBranch, isALUreg, isALUimm;
    logic [3:0] aluControl, aluControlT;
    logic isShamt, isShamtT;

    logic [18:0] testvectors [1000:0];
    logic [31:0] vectornum, errors;

    AluDecoder dut(
        funct3, funct7, instr_5, isBranch, isALUreg, 
        isALUimm, aluControl, isShamt
    );

    initial begin
        $readmemb("aluDecoder.tv", testvectors);
        vectornum = 0; errors = 0;
        #2;
    end

    always begin
        clk <= 1; #5;     
        clk <= 0; #5;     
    end

    always @(posedge clk) begin
        #1; {funct3, funct7, instr_5, isBranch, isALUreg, 
        isALUimm, aluControlT, isShamtT} = testvectors[vectornum];
    end

    always @(negedge clk)
        begin
            if ({aluControl, isShamt} !== {aluControlT, isShamtT}) begin
                $display("Error: output = %b (%b expected)", {aluControl, isShamt}, {aluControlT, isShamtT});
                $display("vectornum %b", vectornum);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 'x) begin 
                $display("%d tests completed with %d errors", vectornum, errors);
                $finish;
            end
        end

endmodule
