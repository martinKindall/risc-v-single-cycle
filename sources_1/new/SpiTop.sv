`timescale 1ns / 1ps

module spiTop(
    input  logic         clk,  // 100 Mhz
    input  logic         i_clk,      // System Clock (Must be <= 50MHz)
    input  logic         i_reset,

    input  logic i_spi_enable,
    input  logic i_spi_release,
    input  logic [21:0] i_dmem_addr,
    input  logic [9:0] i_dmem_data,
    output logic o_spi_ack,
    output logic [31:0]  o_spi_data,

    // External SPI Physical Pins
    output logic         o_spi_cs_n, // Chip Select
    inout  logic         [3:0] qspi_d
);
    typedef enum logic {IDLE, BUSY} state_t;
    state_t state;

    logic [23:0] i_spi_addr;

    assign i_spi_addr = {4'h3, i_dmem_addr[21:2]};

    logic [9:0] n_bytes_to_read;

    logic   i_wb_cyc = 0, i_wb_stb = 0; 
    logic [23:0] i_wb_addr;

    logic   o_wb_stall, o_wb_ack;
    logic [31:0] o_wb_data;

    // Read buffer
    logic [31:0] buffer[1023:0];

    logic [9:0] wb_req_count;
    logic [9:0] wb_ack_count;

    // Internal signal for the SPI Clock
    // In SV, 'logic' can be connected to module outputs (unlike 'reg' in Verilog)
    logic w_spi_sck_internal;

    localparam int unsigned WB_STEP = 1;

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            o_spi_ack    <= 1'b0;
            i_wb_addr    <= 24'b0;
            wb_req_count <= 10'b0;
            wb_ack_count <= 10'b0;
            n_bytes_to_read <= 10'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (i_spi_enable) begin
                        wb_req_count <= 10'b0;
                        wb_ack_count <= 10'b0;

                        o_spi_ack   <= 1'b0;

                        i_wb_cyc    <= 1'b1;
                        i_wb_stb    <= 1'b1;
                        i_wb_addr   <= i_spi_addr;
                        n_bytes_to_read <= i_dmem_data;
                        
                        state <= BUSY;  
                    end
                end
                BUSY: begin
                    // ---------------------------------------------------------
                    // 1. Request Logic (The "Master" Side)
                    // ---------------------------------------------------------
                    // Keep requesting as long as we haven't sent 4 requests
                    // and the bus is not stalled.
                    if ({wb_req_count, 2'b00} < (n_bytes_to_read + 3'h4)) begin
                        if (~o_wb_stall) begin
                            // Standard Wishbone Pipelining:
                            // We can update address and STB if stall is low.
                            i_wb_addr    <= i_wb_addr + 3'h4;
                            wb_req_count <= wb_req_count + WB_STEP;
                        end
                    end else begin
                        // Once the requests are issued, drop Strobe.
                        // Keep Cycle high until the very end.
                        i_wb_stb <= 1'b0;
                    end

                    // ---------------------------------------------------------
                    // 2. Data Capture Logic (The "Slave" Response)
                    // ---------------------------------------------------------
                    if (o_wb_ack) begin
                        // Capture data into the buffer
                        buffer[wb_ack_count] <= o_wb_data;
                        wb_ack_count         <= wb_ack_count + WB_STEP;
                    end

                    // ---------------------------------------------------------
                    // 3. Completion Check
                    // ---------------------------------------------------------
                    // Cleaner completion check handling the 'current' cycle ack:
                    if (o_wb_ack && ({wb_ack_count, 2'b00} >= {2'b00, n_bytes_to_read})) begin
                        i_wb_cyc   <= 1'b0; // End the Wishbone cycle
                        o_spi_ack  <= 1'b1; // Signal top-level completion

                        state      <= IDLE;
                    end
                end
            endcase
        end
    end

    logic [31:0] w_data_raw;
    
    assign w_data_raw = buffer[i_dmem_addr[11:2]];

    always_comb begin
        o_spi_data = {w_data_raw[7:0], w_data_raw[15:8], w_data_raw[23:16], w_data_raw[31:24]};
    end

    logic [3:0] w_qspi_io_t; // Tristate control (1=Input, 0=Output) 
    logic [3:0] w_qspi_io_i; // Input from Pin to Core
    logic [3:0] w_qspi_io_o; // Output from Core to Pin

    logic [1:0] o_qspi_mod;

    // Logic for Tristate (T=1 is Input/High-Z, T=0 is Output)
    assign w_qspi_io_t[0] = (o_qspi_mod == 2'b11) ? 1'b1 : 1'b0; // Input only in Quad Read
    assign w_qspi_io_t[1] = (o_qspi_mod == 2'b11) || (o_qspi_mod == 2'b00) ? 1'b1 : 1'b0; // Input in Read OR Normal SPI
    assign w_qspi_io_t[2] = (o_qspi_mod == 2'b11) || (o_qspi_mod == 2'b00) ? 1'b1 : 1'b0; // Input in Read OR Normal SPI
    assign w_qspi_io_t[3] = (o_qspi_mod == 2'b11) || (o_qspi_mod == 2'b00) ? 1'b1 : 1'b0; // Input in Read OR Normal SPI

    genvar k;
    generate
    for (k = 0; k < 4; k = k + 1) begin : QSPI_IOBUF
        IOBUF iobuf_qspi (
            .O (w_qspi_io_i[k]),   // Buffer Output (to qflexpress i_qspi_dat)
            .IO(qspi_d[k]),        // Physical Pin (top level port inouts)
            .I (w_qspi_io_o[k]),   // Buffer Input  (from qflexpress o_qspi_dat)
            .T (w_qspi_io_t[k])    // Tristate Control (calculated above)
        );
    end
    endgenerate

    qflexpress #(
        .OPT_CFG(1'b0),
        .RDDELAY(1),
        .NDUMMY(5),
        .OPT_STARTUP(1'b1)
    ) u_qflexpress(
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_wb_cyc   (i_wb_cyc),
        .i_wb_stb   (i_wb_stb),
        .i_cfg_stb  (1'b0),
        .i_wb_we    (1'b0),
        .i_wb_addr  (i_wb_addr),
        .i_wb_data  (32'b0),
        .o_wb_stall (o_wb_stall),
        .o_wb_ack   (o_wb_ack),
        .o_wb_data  (o_wb_data),
        .o_qspi_sck  (w_spi_sck_internal),
        .o_qspi_cs_n (o_spi_cs_n),
        .o_qspi_mod (o_qspi_mod),
        .o_qspi_dat (w_qspi_io_o),
        .i_qspi_dat (w_qspi_io_i)
    );

    // 2. Instantiate STARTUPE2 for CCLK Access
    // -----------------------------------------------------------
    // The STARTUPE2 primitive is specific to Xilinx 7-Series (Artix-7).
    // It routes the internal SPI clock to the dedicated CCLK pin.

    STARTUPE2 #(
        .PROG_USR("FALSE"),
        .SIM_CCLK_FREQ(0.0)
    ) u_startupe2 (
        .CFGCLK   (),
        .CFGMCLK  (),
        .EOS      (),
        .PREQ     (),
        .CLK      (1'b0),
        .GSR      (1'b0),
        .GTS      (1'b0),
        .KEYCLEARB(1'b1),
        .PACK     (1'b0),
        
        .USRCCLKO (~i_clk & w_spi_sck_internal), 
        
        // Enable the user clock (Active High to Disable, so 0 is Enable)
        .USRCCLKTS(1'b0),              
        
        // Drive DONE pin High
        .USRDONEO (1'b1),               
        .USRDONETS(1'b1)               
    );

endmodule
