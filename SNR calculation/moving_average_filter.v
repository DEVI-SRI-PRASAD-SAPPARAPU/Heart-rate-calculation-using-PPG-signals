module moving_average_filter #(parameter DATA_WIDTH = 16, WINDOW_SIZE = 5) (
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] data_out,  // Input signal
    output reg [DATA_WIDTH-1:0] smoothed_signal
);

    reg [DATA_WIDTH-1:0] buffer [0:WINDOW_SIZE-1];
    reg [DATA_WIDTH+12:0] sum;
    reg [2:0] index;
    reg [2:0] count;
    integer i;

    // Declare old_value properly here
    reg [DATA_WIDTH-1:0] old_value;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 0;
            index <= 0;
            count <= 0;
            smoothed_signal <= 0;
            old_value <= 0;
            for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
                buffer[i] <= 0;
            end
        end else begin
            // Store old value BEFORE overwriting
            old_value <= buffer[index];

            // Update buffer
            buffer[index] <= data_out;

            // Update sum properly
            if (count >= WINDOW_SIZE) begin
                sum <= sum - old_value + data_out;
            end else begin
                sum <= sum + data_out;
                count <= count + 1;
            end

            // Increment index
            index <= (index == WINDOW_SIZE-1) ? 0 : index + 1;

            // Calculate smoothed output
            if (count >= WINDOW_SIZE) begin
                smoothed_signal <= (sum + (WINDOW_SIZE/2)) / WINDOW_SIZE;
            end else begin
                smoothed_signal <= (sum + (count/2)) / count;
            end
        end
    end
endmodule
