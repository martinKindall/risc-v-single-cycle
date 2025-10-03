
module IODriver(
    input logic clk, reset, enable,
    input logic [31:0] addr, memWdata,
    output logic [4:0] leds
);
    localparam IO_LEDS_bit = 0;
    logic [29:0] wordAddr;

    always_ff @(posedge clk)
        if (reset)
            leds <= 5'b0;
        else if(enable & wordAddr[IO_LEDS_bit])
            leds <= memWdata[4:0];

    assign wordAddr = addr[31:2];

endmodule
