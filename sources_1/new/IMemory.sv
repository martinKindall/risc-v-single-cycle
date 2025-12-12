
module IMemory(
    input logic [11:0] a,
    output logic [31:0] rd
);

    logic [31:0] ROM[4091:0];

    initial
        $readmemh("imemfile.dat", ROM);

    assign rd = ROM[a];

endmodule
