`timescale 1ns / 1ps


module vga_controller (
    input  logic clk, // System clock 25 mhz
    input  logic reset,      // System reset (active high)
    output logic video_on,   // Active high during visible display area
    output logic hsync,      // Horizontal sync pulse
    output logic vsync,      // Vertical sync pulse
    output logic [9:0] x,    // Current pixel x-coordinate (0-799)
    output logic [9:0] y     // Current pixel y-coordinate (0-524)
);

    // VESA 640x480 @ 60Hz Timings (800x525 total)
    // Horizontal Timing (in pixels/clocks)
    parameter H_DISPLAY       = 640; // Horizontal display area
    parameter H_FRONT_PORCH   = 16;  // Front porch
    parameter H_SYNC_PULSE    = 96;  // Sync pulse width
    parameter H_BACK_PORCH    = 48;  // Back porch
    parameter H_TOTAL         = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // 800
    parameter H_SYNC_START    = H_DISPLAY + H_FRONT_PORCH;                             // 656
    parameter H_SYNC_END      = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE;              // 752

    // Vertical Timing (in lines)
    parameter V_DISPLAY       = 480; // Vertical display area
    parameter V_FRONT_PORCH   = 10;  // Front porch
    parameter V_SYNC_PULSE    = 2;   // Sync pulse width
    parameter V_BACK_PORCH    = 33;  // Back porch
    parameter V_TOTAL         = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; // 525
    parameter V_SYNC_START    = V_DISPLAY + V_FRONT_PORCH;                             // 490
    parameter V_SYNC_END      = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE;              // 492

    // --- Counters ---
    logic [9:0] h_count_reg, v_count_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            h_count_reg <= 0;
            v_count_reg <= 0;
        end else begin
            // Horizontal Counter
            if (h_count_reg == H_TOTAL - 1) begin
                h_count_reg <= 0;
                // Vertical Counter (increments when horizontal counter wraps)
                if (v_count_reg == V_TOTAL - 1) begin
                    v_count_reg <= 0;
                end else begin
                    v_count_reg <= v_count_reg + 1;
                end
            end else begin
                h_count_reg <= h_count_reg + 1;
            end
        end
    end
    // -----

    logic hsync_next, vsync_next, video_on_next;

    always_comb begin
        hsync_next = ~((h_count_reg >= H_SYNC_START) && (h_count_reg < H_SYNC_END));
        
        vsync_next = ~((v_count_reg >= V_SYNC_START) && (v_count_reg < V_SYNC_END));

        video_on_next = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            hsync    <= 1'b1;
            vsync    <= 1'b1;
            video_on <= 1'b0;
            x        <= 0;
            y        <= 0;
        end else begin
            hsync    <= hsync_next;
            vsync    <= vsync_next;
            video_on <= video_on_next;
            x <= h_count_reg;
            y <= v_count_reg;
        end
    end

endmodule
