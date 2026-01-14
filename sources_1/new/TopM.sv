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
    output logic [11:0] rgb,         // 12 FPGA pins for RGB(4 per color)
    //spi
    output logic o_spi_cs_n,
    inout  logic [3:0] qspi_d
);
    logic slow_clk;
    logic clk_locked;

    clk_wiz_25mhz clkgen (
        .clk_in1(clk),
        .reset(reset),
        .clk_out1(slow_clk),
        .locked(clk_locked)
    );

    logic [21:0] dmem_addr;
    logic [15:0] dmem_data;
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

    // Spi driver
    logic i_spi_enable, i_spi_release = 0;
    logic o_spi_ack;
    logic [31:0] o_spi_data, millis_counter;

    // Framebuffer control
    logic fbuffer_ctrl, fbuffer_enable, vga_copy_pending;

    RiscVTop risc(
        .clk(clk),
        .slow_clk(slow_clk),
        .keyboard_data(keyboard_data),
        .r_data_vga_cpu(r_data_vga_cpu),
        .reset(reset2 | ~clk_locked),
        .led_segment(led_segment),
        .anode_activate(anode_activate),
        .dp(dp),
        .o_dmem_addr(dmem_addr),
        .dmem_data(dmem_data),
        .char_write_enable(char_write_enable),
        .char_read_enable(char_read_enable),
        .keyboard_clear_on_read(keyboard_clear_on_read),
        .spi_enable(i_spi_enable),
        .fbuffer_ctrl(fbuffer_ctrl),
        .fbuffer_enable(fbuffer_enable),
        .spi_ack(o_spi_ack),
        .spi_data(o_spi_data),
        .millis_counter(millis_counter),
        .vga_copy_pending(vga_copy_pending)
    );

    vga_test vga(
        .clk(slow_clk),
        .reset(reset3 | ~clk_locked),
        .sw(sw),
        .i_dmem_addr({dmem_addr[15:0]}),
        .dmem_data(dmem_data),
        .char_write_enable(char_write_enable),
        .char_read_enable(char_read_enable),
        .hsync_staged(hsync_staged),
        .vsync_staged(vsync_staged),
        .rgb(rgb),
        .r_data_vga_cpu(r_data_vga_cpu),
        .fbuffer_ctrl(fbuffer_ctrl),
        .fbuffer_enable(fbuffer_enable),
        .copy_pending(vga_copy_pending)
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

    spiTop spi(
        .clk(clk),
        .i_clk(slow_clk),
        .i_reset(reset4 | ~clk_locked),
        .i_spi_enable(i_spi_enable),
        .i_spi_release(i_spi_release),
        .i_dmem_addr(dmem_addr),
        .i_dmem_data(dmem_data[9:0]),
        .o_spi_ack(o_spi_ack),
        .o_spi_data(o_spi_data),
        .o_spi_cs_n(o_spi_cs_n),
        .qspi_d(qspi_d)
    );

    Millis_counter millis(
        .clk_25_mhz(slow_clk),
        .rst(reset2 | ~clk_locked),
        .millis(millis_counter)
    );

    assign keyboard_data = {6'b0, keyboard_data_ready_r, on_shift, scancode_filtered};

endmodule
