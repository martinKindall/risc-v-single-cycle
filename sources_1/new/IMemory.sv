
module IMemory(
    input logic [8:0] a,
    output logic [31:0] rd
);

    logic [31:0] ROM[511:0];

    initial
        $readmemh("imemfile.dat", ROM);

    assign rd = ROM[a];

endmodule
