`timescale 1ns / 1ps

module FlopR(
    input logic clk, reset,
    input logic [31:0] d,
    output logic [31:0] q);
    
    always_ff @(posedge clk)
        if (reset)
            q <= 0;
        else
            q <= d;
    
endmodule
