`timescale 1ns / 1ps


module TopM(
    input logic clk, reset, reset2, reset3, reset4, ps2_clk, ps2_data,
    output logic [6:0] led_segment,
    output logic [3:0] anode_activate,
    output logic dp,
    // vga
    input  logic [11:0] sw,
    output logic        hsync_staged, 
    output logic        vsync_staged,
    output logic [11:0] rgb         // 12 FPGA pins for RGB(4 per color)     
);
    logic slow_clk;
    logic clk_locked;

    clk_wiz_25mhz clkgen (
        .clk_in1(clk),
        .reset(reset),
        .clk_out1(slow_clk),
        .locked(clk_locked)
    );

    logic [11:0] char_write_read_addr;
    logic [7:0] char_write_data;
    logic [7:0] r_data_vga_cpu;
    logic char_write_enable;
    logic char_read_enable;

    logic [15:0] keyboard_data;
    logic keyboard_clear_on_read;
    logic [7:0] scancode_filtered;
    logic keyboard_data_ready;
    logic keyboard_data_ready_r;

    always_ff @(posedge slow_clk) begin
        if (reset4 | ~clk_locked | keyboard_clear_on_read)
            keyboard_data_ready_r <= 1'b0;
        else if (keyboard_data_ready)
            keyboard_data_ready_r <= 1'b1;
    end

    RiscVTop risc(
        .clk(clk),
        .slow_clk(slow_clk),
        .keyboard_data(keyboard_data),
        .r_data_vga_cpu(r_data_vga_cpu),
        .reset(reset2 | ~clk_locked),
        .led_segment(led_segment),
        .anode_activate(anode_activate),
        .dp(dp),
        .char_write_read_addr(char_write_read_addr),
        .char_write_data(char_write_data),
        .char_write_enable(char_write_enable),
        .char_read_enable(char_read_enable),
        .keyboard_clear_on_read(keyboard_clear_on_read)
    );

    vga_test vga(
        .clk(slow_clk),
        .reset(reset3 | ~clk_locked),
        .sw(sw),
        .char_write_read_addr(char_write_read_addr),
        .char_write_data(char_write_data),
        .char_write_enable(char_write_enable),
        .char_read_enable(char_read_enable),
        .hsync_staged(hsync_staged),
        .vsync_staged(vsync_staged),
        .rgb(rgb),
        .r_data_vga_cpu(r_data_vga_cpu)
    );

    logic on_shift;

    PS2Receiver receiver(
        .clk(slow_clk),
        .reset(reset4 | ~clk_locked),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .scancode(scancode_filtered),
        .oflag(keyboard_data_ready),
        .on_shift(on_shift)
    );

    assign keyboard_data = {6'b0, keyboard_data_ready_r, on_shift, scancode_filtered};

endmodule
