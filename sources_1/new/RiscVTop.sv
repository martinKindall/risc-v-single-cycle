`timescale 1ns / 1ps

module RiscVTop(
   input logic clk, slow_clk, reset, spi_ack, vga_copy_pending,
   input logic [15:0] keyboard_data,
   input logic [7:0] r_data_vga_cpu,
   input logic [31:0] spi_data, millis_counter,
   output logic [6:0] led_segment,
   output logic [3:0] anode_activate,
   output logic dp,
   output logic [21:0] o_dmem_addr,
   output logic [15:0] dmem_data,
   output logic char_write_enable,
   output logic char_read_enable,
   output logic keyboard_clear_on_read,
   output logic spi_enable,     
   output logic fbuffer_ctrl,
   output logic fbuffer_enable
);

    logic [4:0] leds;

    logic [31:0] pc, instr, memWdata, addr, aluIn1, aluIn2, Simm, Jimm, Bimm, Iimm, memRdata;
    logic [4:0] rs1Id, rs2Id, rdId;
    logic [3:0] memWMask, aluControl;
    logic isALUreg, 
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI,
        isAUIPC,
        isALUimm,
        isLoad, 
        isStore,
        isShamt;

    logic [15:0] displayed_number, short_segments;

    SevenSegmentTop sevenSegmentTop(
        .clk(clk),
        .displayed_number(displayed_number),
        .led_segment(led_segment),
        .anode_activate(anode_activate),
        .dp(dp));

    RiscV riscv(slow_clk, reset, spi_ack, vga_copy_pending, keyboard_data, r_data_vga_cpu, spi_data, millis_counter, pc, instr, memWdata, addr, aluIn1, aluIn2, Simm, Jimm, Bimm, Iimm, memRdata, rs1Id, rs2Id, rdId, memWMask, aluControl,
        isALUreg, 
        regWrite,
        isJAL,
        isJALR,
        isBranch,
        isLUI,
        isAUIPC,
        isALUimm,
        isLoad, 
        isStore,
        isShamt,
        leds,
        short_segments,
        o_dmem_addr,
        dmem_data,
        char_write_enable,
        char_read_enable,
        keyboard_clear_on_read,
        spi_enable,
        fbuffer_ctrl,
        fbuffer_enable
    );

    assign displayed_number = short_segments;

endmodule
