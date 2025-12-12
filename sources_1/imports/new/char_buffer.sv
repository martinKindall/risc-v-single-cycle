`timescale 1ns / 1ps


module char_buffer(
    input  logic clk,
    input  logic reset,     
    input  logic [11:0] w_r_address,
    input  logic [11:0] r_address,
    input  logic [7:0] w_data,
    input  logic w_enable,
    input  logic r_enable,
    input  logic r_data_vga_cpu_enable,
    output logic [7:0] r_data_vga,
    output logic [7:0] r_data_vga_cpu
);

   // BRAM_TDP_MACRO: True Dual Port RAM
   //                 Artix-7
   // Xilinx HDL Language Template, version 2025.1

   //////////////////////////////////////////////////////////////////////////
   // DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width //
   // ===============|===========|===========|===============|=============//
   //     19-36      |  "36Kb"   |    1024   |    10-bit     |    4-bit    //
   //     10-18      |  "36Kb"   |    2048   |    11-bit     |    2-bit    //
   //     10-18      |  "18Kb"   |    1024   |    10-bit     |    2-bit    //
   //      5-9       |  "36Kb"   |    4096   |    12-bit     |    1-bit    //
   //      5-9       |  "18Kb"   |    2048   |    11-bit     |    1-bit    //
   //      3-4       |  "36Kb"   |    8192   |    13-bit     |    1-bit    //
   //      3-4       |  "18Kb"   |    4096   |    12-bit     |    1-bit    //
   //        2       |  "36Kb"   |   16384   |    14-bit     |    1-bit    //
   //        2       |  "18Kb"   |    8192   |    13-bit     |    1-bit    //
   //        1       |  "36Kb"   |   32768   |    15-bit     |    1-bit    //
   //        1       |  "18Kb"   |   16384   |    14-bit     |    1-bit    //
   //////////////////////////////////////////////////////////////////////////

    BRAM_TDP_MACRO #(
      .BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .DEVICE("7SERIES"), // Target device: "7SERIES" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(8'h00),  // Initial values on port A output port
      .INIT_B(8'h00), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (8),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .READ_WIDTH_B (8),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY",
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(8'h00), // Set/Reset value for port A output
      .SRVAL_B(8'h00), // Set/Reset value for port B output
      .WRITE_MODE_A("READ_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("READ_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(8), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .WRITE_WIDTH_B(8) // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
   ) BRAM_TDP_MACRO_inst (
      .DOA(r_data_vga_cpu),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(r_data_vga),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(w_r_address),   // Input port-A address, width defined by Port A depth
      .ADDRB(r_address),   // Input port-B address, width defined by Port B depth
      .CLKA(clk),     // 1-bit input port-A clock
      .CLKB(clk),     // 1-bit input port-B clock
      .DIA(w_data),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(8'b0),       // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(r_data_vga_cpu_enable | w_enable),       // 1-bit input port-A enable
      .ENB(r_enable),       // 1-bit input port-B enable
      .REGCEA(1'b0), // 1-bit input port-A output register enable
      .REGCEB(1'b0), // 1-bit input port-B output register enable
      .RSTA(reset),     // 1-bit input port-A reset
      .RSTB(reset),     // 1-bit input port-B reset
      .WEA(w_enable),       // Input port-A write enable, width defined by Port A depth
      .WEB(1'b0)        // Input port-B write enable, width defined by Port B depth
   );

    // End of BRAM_TDP_MACRO_inst instantiation

endmodule
