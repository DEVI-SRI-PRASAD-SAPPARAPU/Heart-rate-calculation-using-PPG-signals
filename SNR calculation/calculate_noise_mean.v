module calculate_noise_mean #(parameter DATA_WIDTH = 16, MEMORY_DEPTH = 5968)(
    input wire clk,
    input wire reset,
    input wire valid_noise,
    input wire signed [DATA_WIDTH-1:0] noise_signal,
    output reg signed [DATA_WIDTH+13:0] noise_sum,  // Signed accumulator
    output reg signed [DATA_WIDTH-1:0] noise_mean,  // Final signed mean
    output reg done_noise_mean
);

    reg [12:0] sample_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            noise_sum <= 0;
            noise_mean <= 0;
            sample_count <= 0;
            done_noise_mean <= 0;
        end else if (!done_noise_mean && valid_noise) begin
            if (sample_count < MEMORY_DEPTH) begin
                noise_sum <= noise_sum + noise_signal;
                sample_count <= sample_count + 1;
            end else if (sample_count == MEMORY_DEPTH) begin
                noise_mean <= noise_sum / MEMORY_DEPTH;
                done_noise_mean <= 1;
            end
        end
    end

endmodule