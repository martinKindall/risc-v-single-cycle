
module Datapath_TB;

    logic clk, reset, 
        memtoreg, isALUreg, regWrite, 
        isJAL, isJALR, isBranch, isLUI, 
        isAUIPC, isLoad, isStore, isShamt;

    logic [2:0] funct3;
    logic [3:0] aluControl;
    logic [31:0] instr, memRdata;
    logic [31:0] pc, aluOut, memWdata, aluIn1, aluIn2;
    logic [3:0] memWMask;
    logic isZero;

    logic [31:0] counter;

    Datapath dut(clk, reset, 
        isALUreg, regWrite, isJAL, 
        isJALR, isBranch, isLUI, isAUIPC, 
        isLoad, isStore, isShamt,
        funct3, aluControl, instr, memRdata,
        pc, aluOut, memWdata, aluIn1, aluIn2, memWMask, isZero);

    initial begin
        counter = 0;
        reset = 1; #15; 
        reset = 0; #2;
    end

    always begin
        clk <= 1; #5;     
        clk <= 0; #5;     
    end

    always @(posedge clk) begin
        #1; counter = counter + 1;
    end

    always @(negedge clk) begin
        if (counter == 4'h5) begin
            $finish;
        end
    end

endmodule
