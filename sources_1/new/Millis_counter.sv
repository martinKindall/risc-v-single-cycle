`timescale 1ns / 1ps


module Millis_counter(
    input  logic        clk_25_mhz,
    input  logic        rst,
    output logic [31:0] millis
);

    logic [14:0] cycle_cnt;

    always_ff @(posedge clk_25_mhz) begin
        if (rst) begin
            cycle_cnt <= 15'd0;
            millis    <= 32'd0;
        end else begin
            if (cycle_cnt == 15'd24999) begin
                cycle_cnt <= 15'd0;
                millis    <= millis + 1'b1;
            end else begin
                cycle_cnt <= cycle_cnt + 1'b1;
            end
        end
    end

endmodule
