`timescale 1ns / 1ps

module Keyboard (
    input  logic clk,
    input  logic reset,
    input  logic ps2_clk,       
    input  logic ps2_data,     
    output logic [7:0] scancode,
    output logic data_ready,
    output logic error_flag
);

    logic [2:0] ps2_clk_sync;
    logic [1:0] ps2_data_sync;
    logic ps2_clk_falling;

    logic [10:0] shift_logic;
    logic [3:0]  bit_count;

    logic [17:0] watchdog_timer;

    // --- Synchronization Logic ---
    always_ff @(posedge clk) begin
        if (reset) begin
            ps2_clk_sync  <= 3'b000;
            ps2_data_sync <= 2'b00;
        end else begin
            ps2_clk_sync  <= {ps2_clk_sync[1:0], ps2_clk};
            ps2_data_sync <= {ps2_data_sync[0], ps2_data};
        end
    end

    // Detect falling edge on stabilized signals
    assign ps2_clk_falling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    logic synced_data;
    assign synced_data = ps2_data_sync[1];

    // --- Main State Machine ---
    always_ff @(posedge clk) begin
        if (reset) begin
            bit_count      <= 4'b0;
            shift_logic    <= 11'b0;
            scancode       <= 8'b0;
            data_ready     <= 1'b0;
            error_flag     <= 1'b0;
            watchdog_timer <= 18'b0;
        end else begin
            // Default assignment (auto-clear data_ready)
            data_ready <= 1'b0;
            error_flag <= 1'b0;

            if (ps2_clk_falling) begin
                shift_logic <= {synced_data, shift_logic[10:1]};
                bit_count <= bit_count + 1;
                watchdog_timer <= 18'b0;

                if (bit_count == 10) begin
                    bit_count <= 4'b0;
                    if ((shift_logic[1] == 1'b0) && (synced_data == 1'b1) && (^(shift_logic[10:2]) == 1)) begin // initial and stop bit
                        scancode   <= shift_logic[9:2];
                        data_ready <= 1'b1;
                    end else begin
                        error_flag <= 1'b1;
                        data_ready <= 1'b0;
                    end
                end
            end else begin
                // Watchdog Logic
                watchdog_timer <= watchdog_timer + 1;
                if (watchdog_timer == 260000) begin
                    bit_count <= 4'b0;
                    watchdog_timer <= 18'b0;
                end
            end
        end
    end

endmodule
