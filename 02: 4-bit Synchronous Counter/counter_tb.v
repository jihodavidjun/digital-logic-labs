// counter_tb.v — testbench for counter.v
`timescale 1ns/1ps

module counter_tb;
    reg clk;
    reg reset;

    // Output
    wire [3:0] q;

    // Instantiate DUT
    counter dut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    // Clock generator: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;   // invert every 5 ns -> 10 ns period

    // Pretty printer
    always @(posedge clk) begin
        $display("t=%0t ns | reset=%b | q=%0d (0x%0h)", $time, reset, q, q);
    end

    // Test sequence
    initial begin
        // For waveform viewers (EPWave/GTKWave)
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        // One posedge
        reset = 1;
        #12;               
        reset = 0;

        // Wrap occurs at 16 ticks
        #200;

        // Synchronous reset
        reset = 1; #10;      // ensure it overlaps a posedge
        reset = 0;

        // Extra
        #80;

        $display("Counter TB finished.");
        $finish;
    end
endmodule