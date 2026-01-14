`timescale 1ns / 1ps

/*
    Remember x and y are one cycle behing signal o_data_b. Memory has latency of 1 cycle.
*/

module FrameBuffer_ctrl(
    input logic clk, i_enable_w_a,
    input logic [9:0] x, y,
    input logic [14:0] i_addr_a,
    input logic [15:0] i_data_a,
    output logic [15:0] o_data_a,
    output logic [15:0] o_data_b
);

    localparam IMG_W = 195;
    localparam IMG_H = 146;

    logic [14:0] i_addr_b;
    logic [15:0] ram_data_b;
    logic        region_active;
    logic        region_active_staged;

    framebuffer_0 fbuffer_0 (
        .addra(i_addr_a),
        .clka(clk),
        .dina(i_data_a),
        .douta(o_data_a),
        .ena({1'b1}),
        .wea(i_enable_w_a),

        .addrb(i_addr_b),
        .clkb(clk),
        .dinb({16'b0}),
        .doutb(ram_data_b),
        .enb({1'b1}),
        .web({1'b0})
    );

    always_comb begin
        if (x < IMG_W && y < IMG_H) begin
            // Address = (Row * Width) + Column
            i_addr_b = (y * IMG_W) + x;
            region_active = 1'b1;
        end else begin
            i_addr_b = '0;
            region_active = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        region_active_staged <= region_active;
    end

    assign o_data_b = region_active_staged ? ram_data_b : 16'h0;

endmodule
