`timescale 1ns / 1ps

module KeyboardTop(
    input  logic clk,
    input  logic reset,
    input  logic ps2_clk,
    input  logic ps2_data,
    input  logic clear_on_read, 
    output logic [7:0] scancode_filtered,
    output logic data_ready,
    output logic error_flag_reg
);
    typedef enum logic [2:0] {IDLE, WAIT_LOW_1, WAIT_F0, WAIT_LOW_2, IGNORE, WAIT_LOW_3} state_t;
    state_t state;

    logic [7:0] scancode_raw;
    logic data_ready_pulse;
    logic error_flag;

    Keyboard keyboard(
        .clk(clk),
        .reset(reset),
        .ps2_clk(ps2_clk),       
        .ps2_data(ps2_data),
        .scancode(scancode_raw),
        .data_ready(data_ready_pulse),
        .error_flag(error_flag)
    );

    always_ff @(posedge clk)
        if (error_flag)
            error_flag_reg <= 1'b1;

    always_ff @(posedge clk)
        if (clear_on_read)
            data_ready <= 1'b0;

    always_ff @(posedge clk) begin
        if (reset) begin
            scancode_filtered <= 8'b0;
            data_ready <= 1'b0;
            state <= IDLE;
            error_flag_reg <= 1'b0;
        end else if (data_ready_pulse) begin
            case (state)
                IDLE: begin
                    if (scancode_raw == 8'hF0) begin  // shouldn't happen in this stage
                        state <= WAIT_LOW_3;
                    end else begin
                        scancode_filtered <= scancode_raw;
                        data_ready <= 1'b1;
                        state <= WAIT_LOW_1;
                    end
                end

                WAIT_F0: begin
                    if (scancode_raw == 8'hF0) begin
                        state <= WAIT_LOW_2;
                    end else begin
                        state <= WAIT_LOW_3;  // shouldn't happen in this stage
                    end
                end

                IGNORE: begin
                    state <= WAIT_LOW_3;
                end
            endcase
        end else begin
            case (state)
                WAIT_LOW_1: begin
                    state <= WAIT_F0;
                end
                WAIT_LOW_2: begin
                    state <= IGNORE;
                end
                WAIT_LOW_3: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
