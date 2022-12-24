
module IMemory(
    input logic [7:0] a,
    output logic [31:0] rd
);

    logic [31:0] ROM[255:0];

    initial
        $readmemb("imemfile.dat", ROM);

    assign rd = ROM[a];

endmodule
