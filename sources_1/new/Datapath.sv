
module Datapath(
    input logic clk, reset,
    input logic isALUreg, regWrite, isJAL, isJALR, isBranch, isLUI, isAUIPC, isLoad, isStore, isShamt,
    input logic [2:0] funct3,
    input logic [3:0] aluControl,
    input logic [31:0] instr, memRdata,
    output logic [31:0] pc, aluOut, memWdata, aluIn1, aluIn2, Simm,
    output logic [4:0] rs1Id, rs2Id, rdId,
    output logic [3:0] memWMask,
    output logic isZero
);
    logic [1:0] memByteAccess, memHalfwordAccess;
    logic [3:0] storeWMask;
    logic [7:0] loadByte;
    logic [15:0] loadHalfword;
    logic [31:0] pcNext, pcplus4, pcplusImm, aluIn2Pre, rd2, wd3, loadData;

    logic [31:0] Uimm, Iimm, Bimm, Jimm;
    logic [4:0] shamt;
    logic loadSign;

    FlopR pcreg(clk, reset, pcNext, pc);
    Adder pcadd1(pc, 32'b100, pcplus4);

    RegisterFile regF(clk, regWrite, rs1Id, rs2Id, rdId, wd3, aluIn1, rd2);

    Alu alu(aluControl, aluIn1, aluIn2, aluOut, isZero);

    assign memByteAccess     = funct3[1:0] == 2'b00;
    assign memHalfwordAccess = funct3[1:0] == 2'b01;

    assign loadHalfword =
            aluOut[1] ? memRdata[31:16] : memRdata[15:0];

    assign loadByte =
            aluOut[0] ? loadHalfword[15:8] : loadHalfword[7:0];

    assign loadData = memByteAccess ? {{24{loadSign}},     loadByte} :
                      memHalfwordAccess ? {{16{loadSign}}, loadHalfword} :
                      memRdata;

    assign memWdata[ 7: 0] = rd2[7:0];
    assign memWdata[15: 8] = aluOut[0] ? rd2[7:0]  : rd2[15: 8];
    assign memWdata[23:16] = aluOut[1] ? rd2[7:0]  : rd2[23:16];
    assign memWdata[31:24] = aluOut[0] ? rd2[7:0]  :
                    aluOut[1] ? rd2[15:8] : rd2[31:24]; 

    assign storeWMask = memByteAccess ?
	            (aluOut[1] ?
		          (aluOut[0] ? 4'b1000 : 4'b0100) :
		          (aluOut[0] ? 4'b0010 : 4'b0001)
                    ) :
	      memHalfwordAccess ?
	            (aluOut[1] ? 4'b1100 : 4'b0011) :
              4'b1111;

    assign memWMask = {4{(isStore)}} & storeWMask;

    assign pcplusImm = pc + (instr[3] ? Jimm[31:0] :
                             instr[4] ? Uimm[31:0] :
                             Bimm[31:0]);

    assign aluIn2Pre = (isALUreg | isBranch) ? rd2 :
                       isStore ? Simm :
                       Iimm;
    assign aluIn2 = isShamt ? {{27{0}}, shamt} : aluIn2Pre;

    assign pcNext = (isBranch && !isZero || isJAL) ? pcplusImm :
                    isJALR ? {aluOut[31:1],1'b0}:
                    pcplus4;

    assign wd3 = (isJAL || isJALR) ? pcplus4 :
                 isLUI ? Uimm :
                 isAUIPC ? pcplusImm : 
                 isLoad ? loadData :
                 aluOut;
                 
    assign rs1Id = instr[19:15];
    assign rs2Id = instr[24:20];
    assign rdId  = instr[11:7];

    assign Uimm = {    instr[31],   instr[30:12], {12{1'b0}}};
    assign Iimm = {{21{instr[31]}}, instr[30:20]};
    assign Simm = {{21{instr[31]}}, instr[30:25],instr[11:7]};
    assign Bimm = {{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
    assign Jimm = {{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

    assign shamt = isALUreg ? rd2[4:0] : instr[24:20];
    assign loadSign = !funct3[2] & (memByteAccess ? loadByte[7] : loadHalfword[15]);

endmodule
