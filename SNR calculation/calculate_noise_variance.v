module calculate_noise_variance #(
    parameter DATA_WIDTH = 16,
    parameter MEMORY_DEPTH = 5968
)(
    input clk,
    input reset,
    input valid_noise,
    input signed [DATA_WIDTH-1:0] noise_signal,
    input signed [DATA_WIDTH-1:0] noise_mean,
    output reg [DATA_WIDTH+12:0] noise_variance,
    output reg done_noise_variance,
    output reg signed [2*DATA_WIDTH-1:0] diff_out,
    output reg [2*DATA_WIDTH+15:0] squared_sum_out
);

    reg signed [2*DATA_WIDTH-1:0] diff;
    reg [2*DATA_WIDTH+15:0] squared_sum;

    // Control signal to stop accumulation
    reg [12:0] sample_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            diff <= 0;
            squared_sum <= 0;
            noise_variance <= 0;
            done_noise_variance <= 0;
            sample_count <= 0;
        end else if (valid_noise && !done_noise_variance) begin
            diff <= noise_signal - noise_mean;
            squared_sum <= squared_sum + (noise_signal - noise_mean) * (noise_signal - noise_mean);
            sample_count <= sample_count + 1;

          if (^noise_signal === 1'bx || sample_count == MEMORY_DEPTH - 1) begin
             noise_variance <= squared_sum / (MEMORY_DEPTH - 1);
             done_noise_variance <= 1;
          end
        end
    end

    // Output latching block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            diff_out <= 0;
            squared_sum_out <= 0;
        end else begin
            diff_out <= diff;
            squared_sum_out <= squared_sum;
        end
    end

endmodule