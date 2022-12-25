
module IODriver(
    input logic clk,
    input logic [31:0] addr, memWdata,
    output logic isIO,
    output logic [4:0] leds
);
    localparam IO_LEDS_bit = 0;

    always_ff @(posedge clk)
        if(isIO & addr[IO_LEDS_bit])
            leds <= memWdata[4:0];

    assign isIO = addr[22];

endmodule
