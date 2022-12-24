`timescale 1ns / 1ps

module FlopR_TB;

    logic clk, reset;
    logic [31:0] d, q;

    FlopR dut(clk, reset, d, q);

    initial begin
        reset = 1; #15; 
        reset = 0; #2;
    end

    always begin
        clk <= 1; #5;     
        clk <= 0; #5;     
    end

    always @(posedge clk) begin
        #1; d <= 32'b100;
    end

    always @(negedge clk) begin
        if (q == 32'b100) begin
            $finish;
        end
    end

endmodule
