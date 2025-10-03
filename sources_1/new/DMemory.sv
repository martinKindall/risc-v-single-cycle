
module DMemory(
    input logic clk, 
    input logic [3:0] memWMask,
    input logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[1023:0];

    always_ff @(posedge clk) begin
        if(memWMask[0]) RAM[a[11:2]][ 7:0 ] <= wd[ 7:0 ];
        if(memWMask[1]) RAM[a[11:2]][15:8 ] <= wd[15:8 ];
        if(memWMask[3]) RAM[a[11:2]][31:24] <= wd[31:24];
        if(memWMask[2]) RAM[a[11:2]][23:16] <= wd[23:16];
    end
    
    assign rd = RAM[a[11:2]];   // it is word aligned

endmodule
