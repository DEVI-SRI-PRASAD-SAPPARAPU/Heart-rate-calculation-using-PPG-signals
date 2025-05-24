module calculate_mean #(parameter DATA_WIDTH = 16, MEMORY_DEPTH = 5968) ( 
    input clk,                      // Clock signal
    input reset,                    // Reset signal
    output reg [DATA_WIDTH-1:0] mean, // Mean value output
    output reg done                 // Completion flag
);
    // Internal Signals
    wire [DATA_WIDTH-1:0] data_out; // Data output from the load_data module
    wire loaded;                    // Indicates when data is loaded
    reg [12:0] read_address;        // Address counter (13 bits for 5968 locations)
    reg [DATA_WIDTH+12:0] sum;      // Accumulator for summing the data (DATA_WIDTH + log2(MEMORY_DEPTH))
    reg [12:0] sample_count;        // Tracks the number of samples processed

    // Instantiate the load_data module
    load_data #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEMORY_DEPTH(MEMORY_DEPTH)
    ) memory_module (
        .clk(clk),
        .reset(reset),
        .read_address(read_address),
        .data_out(data_out),
        .loaded(loaded)
    );

    // Mean Calculation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 0;
            read_address <= 0;
            sample_count <= 0;
            done <= 0;
            mean <= 0;
        end else if (loaded && !done) begin
            if (read_address < MEMORY_DEPTH) begin
                sum <= sum + data_out;          // Accumulate data
                read_address <= read_address + 1; // Increment address
                sample_count <= sample_count + 1; // Increment sample count
            end else if (read_address == MEMORY_DEPTH) begin
               mean <= (MEMORY_DEPTH > 0) ? (sum / MEMORY_DEPTH) : 0;    // Calculate mean after processing all addresses
                done <= 1;                     // Indicate processing is complete
            end
        end
    end
endmodule