`timescale 1ns / 1ps

module SevenSegmentTop(
        input logic clk,
        input logic [15:0] displayed_number,
        output logic [6:0] led_segment,
        output logic [3:0] anode_activate,
        output logic dp);
    
    logic [3:0] led_binary;
    logic [6:0] negSegments;
    
    SevenSegmentCtrl sevenSegmentCtrl(
        .clk(clk),
        .displayed_number(displayed_number),
        .anode_activate(anode_activate),
        .led_binary(led_binary)
    );
    
    SevenSegment sevenSegment(
        .binary(led_binary),
        .segments(negSegments)
    );
    
    assign dp = 1;
    assign led_segment = ~negSegments;
    
endmodule
