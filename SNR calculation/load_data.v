module load_data #(parameter DATA_WIDTH = 16, MEMORY_DEPTH = 5968) (
    input clk,                      // Clock signal
    input reset,                    // Reset signal
    input [12:0] read_address,      // Address to read from memory (13 bits for 5968 locations)
    output reg [DATA_WIDTH-1:0] data_out, // Data output for the given address
    output reg loaded               // Flag indicating data has been loaded
);
    // Internal memory array
    reg [DATA_WIDTH-1:0] memory [0:MEMORY_DEPTH-1];

    // Load the data during initialization
    initial begin
        loaded = 0;
        $readmemh("D:/Xilinx/output_file_hex.txt", memory); // Load data from the file (ensure it's in hexadecimal format)
        loaded = 1; // Indicate data has been successfully loaded
    end
   
    // Provide data based on read address
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_out <= 0; // Clear data_out on reset
    end else if (loaded) begin
        if (read_address < MEMORY_DEPTH) begin
            data_out <= memory[read_address]; // Read valid data
        end else begin
            data_out <= 0; // Handle out-of-bounds address
            //$display("Error: Read address %d is out of bounds!", read_address);
        end
        
    end else begin
        $display("Memory not loaded yet!");
    end
end
endmodule