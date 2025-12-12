`timescale 1ns / 1ps

module vga_test (
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] sw,
    input  logic [11:0] char_write_read_addr,
    input  logic [7:0]  char_write_data,
    input  logic        char_write_enable,
    input  logic        char_read_enable,
    output logic        hsync_staged, 
    output logic        vsync_staged,
    output logic [11:0] rgb,         // 12 FPGA pins for RGB(4 per color)
    output logic [7:0]  r_data_vga_cpu
);
    // stage 0, vga signals

    logic        video_on;
    logic        hsync;
    logic        vsync;

    logic [9:0]  x;
    logic [9:0]  y;

    // stage 1, vga signals

    logic        video_on_stage_1;
    logic        hsync_stage_1;
    logic        vsync_stage_1;

    logic [9:0]  x_stage_1;
    logic [9:0]  y_stage_1;

    // stage 2, vga signals

    logic        video_on_staged;
    logic [11:0] rgb_staged;

    // --

    logic [11:0] rgb_comb;

    // font logic
    logic [11:0] font_address;
    logic [7:0] font_row_x;

    vga_controller vga_c (
        .clk (clk),
        .reset      (reset),
        .video_on   (video_on),
        .hsync      (hsync),
        .vsync      (vsync),
        .x          (x),
        .y          (y)
    );

    logic [7:0] r_data_vga;
    logic [11:0] char_addr;

    char_buffer buffer (
        .clk (clk),
        .reset      (reset),
        .w_r_address      (char_write_read_addr),
        .r_address      (char_addr),
        .w_data      (char_write_data),
        .w_enable      (char_write_enable),
        .r_enable      (1'b1),
        .r_data_vga      (r_data_vga),
        .r_data_vga_cpu      (r_data_vga_cpu),
        .r_data_vga_cpu_enable  (char_read_enable)
    );

    font_rom font_r (
        .a (font_address),
        .rd (font_row_x)
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            video_on_stage_1 <= 1'b0;
            hsync_stage_1 <= 1'b0;
            vsync_stage_1 <= 1'b0;

            x_stage_1 <= 10'b0;
            y_stage_1 <= 10'b0;

            rgb_staged <= 12'b0;
            hsync_staged <= 1'b0;
            vsync_staged <= 1'b0;
            video_on_staged <= 1'b0;
        end
        else begin
            // stage 1
            video_on_stage_1 <= video_on;
            hsync_stage_1 <= hsync;
            vsync_stage_1 <= vsync;
            x_stage_1 <= x;
            y_stage_1 <= y;

            // stage 2

            rgb_staged <= rgb_comb;
            hsync_staged <= hsync_stage_1;
            vsync_staged <= vsync_stage_1;
            video_on_staged <= video_on_stage_1;
        end
    end

    logic [2:0] char_x_col;
    logic pixel_bit;

    always_comb begin
        font_address = {r_data_vga, y_stage_1[3:0]};

        char_x_col = x_stage_1[2:0];
        
        pixel_bit = font_row_x[7 - char_x_col]; 

        if (pixel_bit) begin
            rgb_comb = 12'hFFF;
        end else begin
            rgb_comb = 12'h000;
        end
    end

    // char buffer decoding

    localparam COLS = 80;
    localparam ROWS = 30;

    logic [6:0] char_x;
    logic [4:0] char_y;
    
    always_comb begin
        char_x = x[9:3];
        char_y = y[8:4];
        char_addr = char_y * COLS + char_x;
    end

    // end -- char buffer decoding

    assign rgb = video_on_staged ? rgb_staged : 12'b0;

endmodule
