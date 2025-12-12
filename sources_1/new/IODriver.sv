
module IODriver(
    input logic clk, reset, enable, isStore, isLoad,
    input logic [31:0] addr, memWdata, memRdata,
    input logic [15:0] keyboard_data,
    input logic [7:0] r_data_vga_cpu,
    output logic [4:0] leds,
    output logic [15:0] short_segments,
    output logic [11:0] char_write_read_addr,
    output logic [7:0] char_write_data,
    output logic char_write_enable,
    output logic char_read_enable,
    output logic keyboard_clear_on_read,
    output logic [31:0] memRdataLogic
);
    localparam IO_KEYBOARD_bit = 13;
    localparam IO_LEDS_bit = 12;
    localparam IO_SEV_SEGM_bit = 11;
    localparam IO_VGA_bit = 10;
    logic [29:0] wordAddr;

    logic isIoWrite;
    logic isIoRead;

    always_ff @(posedge clk)
        if (reset) begin
            leds <= 5'b0;
            short_segments <= 16'b0;
        end
        else if(isIoWrite & wordAddr[IO_LEDS_bit])
            leds <= memWdata[4:0];
        else if(isIoWrite & wordAddr[IO_SEV_SEGM_bit])
            short_segments <= memWdata[15:0];

    assign wordAddr = addr[31:2];
    assign isIoWrite = enable & isStore;
    assign isIoRead = enable & isLoad;
    assign keyboard_clear_on_read = isIoWrite & wordAddr[IO_KEYBOARD_bit];
    
    assign char_read_enable = isIoRead & wordAddr[IO_VGA_bit];
    assign char_write_enable = isIoWrite & wordAddr[IO_VGA_bit];  
    assign char_write_read_addr = addr[11:0];
    assign char_write_data = memWdata[7:0];
    
    assign memRdataLogic = 
        (isIoRead & wordAddr[IO_KEYBOARD_bit]) ? {16'b0, keyboard_data} : 
        (char_read_enable ? {r_data_vga_cpu, r_data_vga_cpu, r_data_vga_cpu, r_data_vga_cpu} : 
        memRdata);

endmodule
