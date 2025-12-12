`timescale 1ns / 1ps


module font_rom(
    input logic [11:0] a,
    output logic [7:0] rd
);

    logic [7:0] ROM[4095:0];

    initial
        $readmemh("font_data.mem", ROM);

    assign rd = ROM[a];

endmodule
