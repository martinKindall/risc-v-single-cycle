`timescale 1ns / 1ps

module SevenSegmentCtrl(
    input logic clk,
    input logic [15:0] displayed_number,
    output logic [3:0] anode_activate,
    output logic [3:0] led_binary
);
    logic [19:0] refresh_counter;
    logic [1:0] led_activating_counter;
    
    always_ff @(posedge clk)
        refresh_counter <= refresh_counter + 1;
        
    assign led_activating_counter = refresh_counter[19:18];

    always_comb
        case (led_activating_counter)
            2'b00: begin
                anode_activate <= 4'b0111; 
                led_binary <= displayed_number[15:12];
            end
            2'b01: begin
                anode_activate <= 4'b1011; 
                led_binary <= displayed_number[11:8];
            end
            2'b10: begin
                anode_activate <= 4'b1101; 
                led_binary <= displayed_number[7:4];
            end
            2'b11: begin
                anode_activate <= 4'b1110; 
                led_binary <= displayed_number[3:0];  
            end
        endcase
            
endmodule
