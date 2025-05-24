module calculate_snr_linear #(
    parameter DATA_WIDTH = 29,
    parameter OUTPUT_WIDTH = 32
)(
    input clk,
    input reset,
    input start_snr,  // <---- NEW
    input [DATA_WIDTH-1:0] variance,
    input [DATA_WIDTH-1:0] noise_variance,
    output reg [OUTPUT_WIDTH-1:0] snr_linear,
    output reg done_snr_linear
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            snr_linear <= 0;
            done_snr_linear <= 0;         
        end else if (start_snr && !done_snr_linear) begin
            if (noise_variance != 0) begin
                snr_linear <= variance / noise_variance;
            end else begin
                snr_linear <= 0;
            end
            done_snr_linear <= 1;
        end
    end

endmodule
