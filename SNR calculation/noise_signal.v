`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2025 16:34:22
// Design Name: 
// Module Name: noise_signal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module noise_signal #(parameter DATA_WIDTH = 16) (
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] data_out,         // Original input signal
    input wire [DATA_WIDTH-1:0] smoothed_signal,  // Filtered output from moving_average_filter
    output reg [DATA_WIDTH-1:0] noise_signal      // Noise component
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            noise_signal <= 0;
        end else begin
            noise_signal <= data_out - smoothed_signal; // Compute noise component
        end
    end
endmodule