`timescale 1ns / 1ps

module Decoder_TB;

    logic clk;
    logic [1:0] notUsed;
    logic [31:0] instr;
    logic isALUreg, regWrite, isJAL, 
        isJALR, isBranch, isLUI, 
        isAUIPC, isALUimm, isLoad, isStore;

    logic isALUregT, regWriteT, isJALT, 
        isJALRT, isBranchT, isLUIT, 
        isAUIPCT, isALUimmT, isLoadT, isStoreT;

    logic [43:0] testvectors [1000:0];
    logic [31:0] vectornum, errors;

    Decoder dut(
        instr,
        isALUreg, regWrite, isJAL, 
        isJALR, isBranch, isLUI, 
        isAUIPC, isALUimm, isLoad, 
        isStore
    );

    initial begin
        $readmemh("decoder.tv", testvectors);
        vectornum = 0; errors = 0;
        #2;
    end

    always begin
        clk <= 1; #5;     
        clk <= 0; #5;     
    end

    always @(posedge clk) begin
        #1; {instr, notUsed, isALUregT, regWriteT, isJALT, 
        isJALRT, isBranchT, isLUIT, 
        isAUIPCT, isALUimmT, isLoadT, isStoreT} = testvectors[vectornum];
    end

    always @(negedge clk)
        begin
            if ({isALUreg, regWrite, isJAL, 
                isJALR, isBranch, isLUI, 
                isAUIPC, isALUimm, isLoad, isStore} !== 
                {isALUregT, regWriteT, isJALT, 
                isJALRT, isBranchT, isLUIT, 
                isAUIPCT, isALUimmT, isLoadT, isStoreT}) begin
                $display("Error: output = %b (%b expected)", 
                    {isALUreg, regWrite, isJAL, 
                    isJALR, isBranch, isLUI, 
                    isAUIPC, isALUimm, isLoad, isStore},
                    {isALUregT, regWriteT, isJALT, 
                    isJALRT, isBranchT, isLUIT, 
                    isAUIPCT, isALUimmT, isLoadT, isStoreT});
                $display("vectornum %b", vectornum);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 'x) begin 
                $display("%d tests completed with %d errors", vectornum, errors);
                $finish;
            end
        end

endmodule
