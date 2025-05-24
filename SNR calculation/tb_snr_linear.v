`timescale 1ns / 1ps

module tb_snr_linear();

    reg clk;
    reg reset;

    // Clock generator
    always #5 clk = ~clk;

    // Internal wires and regs
    wire [15:0] data_out;
    wire [15:0] smoothed_signal;
    wire signed [15:0] noise_signal;
    wire [12:0] read_address;
    wire [15:0] mean;
    wire [28:0] variance;
    wire signed [28:0] noise_sum;
    wire signed [15:0] noise_mean;

    wire signed [31:0] diff_out;
    wire [47:0] squared_sum_out;

    wire [28:0] noise_variance;
    wire loaded;
    wire done_mean;
    wire done_variance;
    wire done_noise_mean;
    wire done_noise_variance;

    wire [31:0] snr_linear;
    wire done_snr_linear;

    reg enable_filter;
    reg valid_noise;
    reg snr_start;

    wire [15:0] filter_input = enable_filter ? data_out : 16'd0;

    // Valid_noise controller
    always @(posedge clk or posedge reset) begin
        if (reset)
            valid_noise <= 0;
        else if (done_noise_mean && !done_noise_variance)
            valid_noise <= 1;
        else if (done_noise_variance)
            valid_noise <= 0;
    end

    // SNR start trigger
    always @(posedge clk or posedge reset) begin
        if (reset)
            snr_start <= 0;
        else if (done_variance && done_noise_variance)
            snr_start <= 1;
        else if (done_snr_linear)
            snr_start <= 0;
    end

    // Load data
    load_data data_loader (
        .clk(clk),
        .reset(reset),
        .read_address(read_address),
        .data_out(data_out),
        .loaded(loaded)
    );

    // Filter
    moving_average_filter filter_inst (
        .clk(clk),
        .reset(reset),
        .data_out(filter_input),
        .smoothed_signal(smoothed_signal)
    );

    // Noise extraction
    noise_signal noise_inst (
        .clk(clk),
        .reset(reset),
        .data_out(data_out),
        .smoothed_signal(smoothed_signal),
        .noise_signal(noise_signal)
    );

    // Signal Mean
    calculate_mean mean_inst (
        .clk(clk),
        .reset(reset),
        .mean(mean),
        .done(done_mean)
    );

    // Signal Variance
    calculate_variance var_inst (
        .clk(clk),
        .reset(reset),
        .variance(variance),
        .done_variance(done_variance),
        .read_address(read_address),
        .data_out(data_out)
    );

    // Noise Mean
    calculate_noise_mean noise_mean_inst (
        .clk(clk),
        .reset(reset),
        .valid_noise(done_mean),
        .noise_signal(noise_signal),
        .noise_sum(noise_sum),
        .noise_mean(noise_mean),
        .done_noise_mean(done_noise_mean)
    );

    // Noise Variance
    calculate_noise_variance #( 
        .DATA_WIDTH(16), 
        .MEMORY_DEPTH(5968) 
    ) noise_var_inst (
        .clk(clk),
        .reset(reset),
        .valid_noise(valid_noise),
        .noise_signal(noise_signal),
        .noise_mean(noise_mean),
        .noise_variance(noise_variance),
        .done_noise_variance(done_noise_variance),
        .diff_out(diff_out),
        .squared_sum_out(squared_sum_out)
    );

    // SNR Linear
    calculate_snr_linear snr_inst (
    .clk(clk),
    .reset(reset),
    .start_snr(snr_start),  // connect here
    .variance(variance),
    .noise_variance(noise_variance),
    .snr_linear(snr_linear),
    .done_snr_linear(done_snr_linear)
);


    // Initial block
    initial begin
        clk = 0;
        reset = 1;
        enable_filter = 0;
        snr_start = 0;

        #15 reset = 0;

        wait(loaded);
        $display("Data loaded.");

        #10;
        wait(done_mean);
        $display("Signal mean done.");
        enable_filter = 1;

        #10;
        wait(done_noise_mean);
        $display("Noise mean done: %d", noise_mean);

        #10;
        wait(done_variance);
        $display("Signal variance done: %d", variance);

        #10;
        wait(done_noise_variance);      
        $display("Noise variance done: %d", noise_variance);
        
        #1;
        wait(done_snr_linear);
        $display("SNR Linear Ratio (Q16.16): %d", snr_linear);
        #5;
        
        $stop;
    end

    // Monitor block
    initial begin
        $monitor("Time=%0t | Addr=%d | Data=%d | Smooth=%d | Noise=%d | Mean=%d | Var=%d | NoiseMean=%d | NoiseVar=%d | SNR=%d | DoneMean=%b | DoneVar=%b | DoneNoiseMean=%b | DoneNoiseVar=%b | DoneSNR=%b",
                 $time, read_address, data_out, smoothed_signal, noise_signal, mean, variance,
                 noise_mean, noise_variance, snr_linear,
                 done_mean, done_variance, done_noise_mean, done_noise_variance, done_snr_linear);
    end

endmodule