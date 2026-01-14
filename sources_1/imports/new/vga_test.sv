`timescale 1ns / 1ps

module vga_test (
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] sw,
    input  logic [15:0] i_dmem_addr,
    input  logic [15:0] dmem_data,
    input  logic        char_write_enable,
    input  logic        char_read_enable,
    input  logic        fbuffer_ctrl,
    input  logic        fbuffer_enable,
    output logic        hsync_staged, 
    output logic        vsync_staged,
    output logic [11:0] rgb,         // 12 FPGA pins for RGB(4 per color)
    output logic [7:0]  r_data_vga_cpu,
    output logic copy_pending
);
    // fbuffer ctrl 
    logic [1:0] fbuffer_ctrl_reg;
    logic [15:0] i_addr_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            fbuffer_ctrl_reg <= 2'b0;
            copy_pending <= 1'b0;
            i_addr_reg <= 16'b0;
        end
        else if (fbuffer_ctrl) begin
            fbuffer_ctrl_reg <= dmem_data[1:0];

            if (dmem_data[1] | dmem_data[0]) begin
                copy_pending <= 1'b1;
                i_addr_reg <= 16'b0;
            end
        end

        if (copy_pending) begin
            i_addr_reg <= i_addr_reg + 1'b1;
            
            if (i_addr_reg == 16'hFFFE)
                copy_pending <= 1'b0;
        end
    end

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
        .w_r_address      ({i_dmem_addr[11:0]}),
        .r_address      (char_addr),
        .w_data      (dmem_data[7:0]),
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

    // framebuffer decoding buffer 0
    logic [15:0] o_data_b_0;    // RGB565
    logic [11:0] rgb_fbuffer_0; // RGB444
    logic [11:0] rgb_fbuffer_staged_0;

    always_comb begin
        rgb_fbuffer_0 = {o_data_b_0[15:12], o_data_b_0[10:7], o_data_b_0[4:1]};   
    end

    always_ff @(posedge clk) begin
        if (reset)
            rgb_fbuffer_staged_0 <= 12'b0;
        else
            rgb_fbuffer_staged_0 <= rgb_fbuffer_0;
    end

    // framebuffer decoding buffer 1
    logic [15:0] o_data_b_1;    // RGB565
    logic [11:0] rgb_fbuffer_1; // RGB444
    logic [11:0] rgb_fbuffer_staged_1;

    always_comb begin
        rgb_fbuffer_1 = {o_data_b_1[15:12], o_data_b_1[10:7], o_data_b_1[4:1]};   
    end

    always_ff @(posedge clk) begin
        if (reset)
            rgb_fbuffer_staged_1 <= 12'b0;
        else
            rgb_fbuffer_staged_1 <= rgb_fbuffer_1;
    end

    // end

    always_comb begin
        if (video_on_staged) begin
            if (fbuffer_ctrl_reg == 2'b00)
                rgb = rgb_staged;
            else if (fbuffer_ctrl_reg == 2'b01)
                rgb = rgb_fbuffer_staged_1;
            else if (fbuffer_ctrl_reg == 2'b10)
                rgb = rgb_fbuffer_staged_0;
            else
                rgb = 12'b0;
        end else 
            rgb = 12'b0;
    end

    logic [15:0] i_addr_a;
    logic [15:0] o_data_a_0, i_data_a_0;
    logic [15:0] o_data_a_1, i_data_a_1;

    assign i_addr_a = copy_pending ? i_addr_reg[15:1] : i_dmem_addr[15:1];

    assign i_data_a_0 = fbuffer_ctrl_reg == 2'b01 ? (copy_pending ? o_data_a_1 : dmem_data) : 16'b0;
    assign i_data_a_1 = fbuffer_ctrl_reg == 2'b10 ? (copy_pending ? o_data_a_0 : dmem_data) : 16'b0;

    FrameBuffer_ctrl fbuf_0 (
        .clk(clk),
        .i_enable_w_a((fbuffer_enable | copy_pending) & fbuffer_ctrl_reg[0]),
        .x(x),
        .y(y),
        .i_addr_a(i_addr_a),
        .i_data_a(i_data_a_0),
        .o_data_a(o_data_a_0),
        .o_data_b(o_data_b_0)
    );

    FrameBuffer_ctrl fbuf_1 (
        .clk(clk),
        .i_enable_w_a((fbuffer_enable | copy_pending) & fbuffer_ctrl_reg[1]),
        .x(x),
        .y(y),
        .i_addr_a(i_addr_a),
        .i_data_a(i_data_a_1),
        .o_data_a(o_data_a_1),
        .o_data_b(o_data_b_1)
    );

endmodule
