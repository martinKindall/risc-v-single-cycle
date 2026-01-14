
module IODriver(
    input logic clk, reset, enable, isStore, isLoad, spi_ack, vga_copy_pending,
    input logic [31:0] addr, memWdata, memRdata, spi_data, millis_counter,
    input logic [15:0] keyboard_data,
    input logic [7:0] r_data_vga_cpu,
    output logic [4:0] leds,
    output logic [15:0] short_segments,
    output logic [21:0] o_dmem_addr,
    output logic [15:0] dmem_data,
    output logic char_write_enable,
    output logic char_read_enable,
    output logic keyboard_clear_on_read,
    output logic spi_enable,
    output logic fbuffer_ctrl,
    output logic fbuffer_enable,
    output logic [31:0] memRdataLogic
);
    localparam IO_KEYBOARD_bit = 28;
    localparam IO_VGA_bit = 27;
    localparam IO_MILLIS_bit = 24;
    localparam IO_FBUFFER_bit = 23;
    localparam IO_FBUFFER_CTRL_bit = 22;
    localparam IO_SPI_bit = 21;
    localparam IO_SPI_CTRL_bit = 20;
    logic [29:0] wordAddr;

    logic isIoWrite;
    logic isIoRead;

    always_ff @(posedge clk)
        if (reset) begin
            leds <= 5'b0;
            short_segments <= 16'b0;
        end

    assign wordAddr = addr[31:2];
    assign isIoWrite = enable & isStore;
    assign isIoRead = enable & isLoad;
    assign keyboard_clear_on_read = isIoWrite & wordAddr[IO_KEYBOARD_bit];
    
    assign char_read_enable = isIoRead & wordAddr[IO_VGA_bit];
    assign char_write_enable = isIoWrite & wordAddr[IO_VGA_bit];  
    assign o_dmem_addr = addr[21:0];
    assign dmem_data = memWdata[15:0];
    assign spi_enable = isIoWrite & wordAddr[IO_SPI_CTRL_bit];
    assign fbuffer_ctrl = isIoWrite & wordAddr[IO_FBUFFER_CTRL_bit];
    assign fbuffer_enable = isIoWrite & wordAddr[IO_FBUFFER_bit];
    
    assign memRdataLogic = 
        (isIoRead & wordAddr[IO_KEYBOARD_bit]) ? {16'b0, keyboard_data} : 
        (char_read_enable ? {r_data_vga_cpu, r_data_vga_cpu, r_data_vga_cpu, r_data_vga_cpu} :
        ((isIoRead & wordAddr[IO_SPI_bit]) ? spi_data : 
        ((isIoRead & wordAddr[IO_SPI_CTRL_bit]) ? {31'b0, spi_ack} : 
        ((isIoRead & wordAddr[IO_MILLIS_bit]) ? millis_counter :
        ((isIoRead & wordAddr[IO_FBUFFER_CTRL_bit]) ? {31'b0, vga_copy_pending} :
        memRdata)))));

endmodule
