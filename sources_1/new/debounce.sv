`timescale 1ns / 1ps

module debounce #(
    parameter int COUNT_MAX   = 255,
    parameter int COUNT_WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic I,
    output logic O
);

    logic [COUNT_WIDTH-1:0] count;
    logic Iv;

    always_ff @(posedge clk) begin
        if (reset) begin
            Iv <= 0;
        end else if (I == Iv) begin
            if (count == COUNT_MAX) begin
                O <= I;
            end else begin
                count <= count + 1'b1;
            end
        end else begin
            count <= 1'b0;
            Iv    <= I;
        end
    end

endmodule
