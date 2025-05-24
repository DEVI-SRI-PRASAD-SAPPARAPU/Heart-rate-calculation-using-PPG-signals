module calculate_variance #(parameter DATA_WIDTH = 16, MEMORY_DEPTH = 5968) (
    input clk,
    input reset,
    output reg [DATA_WIDTH+12:0] variance, // Expose variance
    output reg done_variance,             // Expose completion flag
    output reg [12:0] read_address,        // Expose read address
    output wire [DATA_WIDTH-1:0] data_out  // Expose data_out from load_data
);
    // Internal signals
    wire [DATA_WIDTH-1:0] mean;
    wire loaded;
    wire done_mean;
    reg [DATA_WIDTH+24:0] squared_sum;  // Adjusted for accumulation
    reg [12:0] sample_count;

    // Instantiate calculate_mean module
    calculate_mean #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEMORY_DEPTH(MEMORY_DEPTH)
    ) mean_module (
        .clk(clk),
        .reset(reset),
        .mean(mean),
        .done(done_mean)
    );

    // Instantiate load_data module
    load_data #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEMORY_DEPTH(MEMORY_DEPTH)
    ) data_module (
        .clk(clk),
        .reset(reset),
        .read_address(read_address),
        .data_out(data_out),
        .loaded(loaded)
    );

    // Variance Calculation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            squared_sum <= 0;
            read_address <= 0;
            sample_count <= 0;
            done_variance <= 0;
            variance <= 0;
        end else if (loaded && done_mean && !done_variance) begin
            if (read_address < MEMORY_DEPTH) begin
                squared_sum <= squared_sum + ((data_out - mean) * (data_out - mean));
                read_address <= read_address + 1;
            end else if (read_address == MEMORY_DEPTH) begin
                variance <= (MEMORY_DEPTH > 1) ? (squared_sum / (MEMORY_DEPTH-1)) : 0;
                done_variance <= 1;
            end
        end
    end

endmodule