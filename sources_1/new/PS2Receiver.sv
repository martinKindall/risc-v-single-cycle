`timescale 1ns / 1ps

module PS2Receiver(
    input  logic        clk,
    input  logic        reset,
    input  logic        ps2_clk,
    input  logic        ps2_data,
    output logic [7:0]  scancode,
    output logic        oflag,
    output logic        on_shift
);
    
    logic [15:0] keycode;
    logic kclkf, kdataf;
    logic [7:0] datacur;
    logic [7:0] dataprev;
    logic [3:0] cnt;
    logic       flag;
    logic       pflag;
    
    debounce #(
        .COUNT_MAX(19),
        .COUNT_WIDTH(5)
    ) db_clk (
        .clk(clk),
        .reset(reset),
        .I(ps2_clk),
        .O(kclkf)
    );

    debounce #(
        .COUNT_MAX(19),
        .COUNT_WIDTH(5)
    ) db_data (
        .clk(clk),
        .reset(reset),
        .I(ps2_data),
        .O(kdataf)
    );

    // PS/2 Packet Parsing Logic
    // Triggered on the falling edge of the *debounced* PS/2 clock
    always_ff @(negedge kclkf) begin
        case(cnt)
            4'd0: ; // Start bit (Active Low)
            4'd1: datacur[0] <= kdataf;
            4'd2: datacur[1] <= kdataf;
            4'd3: datacur[2] <= kdataf;
            4'd4: datacur[3] <= kdataf;
            4'd5: datacur[4] <= kdataf;
            4'd6: datacur[5] <= kdataf;
            4'd7: datacur[6] <= kdataf;
            4'd8: datacur[7] <= kdataf;
            4'd9: flag       <= 1'b1; // Packet complete
            4'd10: flag      <= 1'b0; // Handshake/Cleanup
        endcase
        
        if (cnt <= 4'd9) 
            cnt <= cnt + 1;
        else if (cnt == 4'd10) 
            cnt <= '0;
    end

    // Output Handling Logic
    // Synchronized to the main system clock
    always_ff @(posedge clk) begin
        if (reset) begin
            oflag <= 1'b0;
            scancode <= 8'b0;
            on_shift <= 1'b0;
        end
        // Detect rising edge of 'flag' (which comes from the kclkf domain)
        else if (flag == 1'b1 && pflag == 1'b0) begin
            keycode  <= {dataprev, datacur};
            dataprev <= datacur;

            if (datacur != 8'hF0 && dataprev != 8'hF0) begin
                if (datacur == 8'h12 | datacur == 8'h59) begin
                    on_shift <= 1'b1;
                end else begin
                    scancode <= datacur;
                    oflag <= 1'b1;
                end
            end else if (datacur == 8'h12 | datacur == 8'h59) begin
                on_shift <= 1'b0;
            end
        end else
            oflag <= 1'b0;

        pflag <= flag;
    end

endmodule
