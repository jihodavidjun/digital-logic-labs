`timescale 1ns/1ps

module heartbeat_counter_tb;

  // Pick a small-ish clock so periods are readable but not too slow.
  localparam integer CLK_HZ = 1000;   
  localparam integer WINDOW_SECONDS = 2;      
  localparam integer WINDOW_CYCLES = CLK_HZ * WINDOW_SECONDS;
  localparam integer SCALE_FACTOR = (60 * CLK_HZ) / WINDOW_CYCLES;  // = 30

  // Testbench signals
  reg  clk = 1'b0;   
  reg  reset = 1'b1;   
  reg  pulse_in = 1'b0;   
  wire [7:0] bpm;       
  wire new_bpm;     

  // 1 kHz → 1,000,000 ns period, 500,000 ns half
  always #500000 clk = ~clk;  

  heartbeat_counter #(
    .WINDOW_CYCLES(WINDOW_CYCLES), 
    .SCALE_FACTOR (SCALE_FACTOR)   
  ) dut (
    .clk (clk),
    .reset (reset),
    .pulse_in(pulse_in),
    .bpm (bpm),
    .new_bpm (new_bpm)
  );

  // Helper Function
  // Wider beat pulses so they show up in the viewer
  localparam integer PULSE_W = 5; // 5 clocks high (~5 ms at 1 kHz)

  function integer ticks_per_beat;
    input integer bpm_i;
    begin
      ticks_per_beat = (CLK_HZ * 60) / bpm_i;
    end
  endfunction

  task drive_bpm;
    input integer bpm_i;
    input integer windows;
    integer ticks, beats, k;
    begin
      ticks = ticks_per_beat(bpm_i);

      // Round up so we never get 0 beats due to integer division
      beats = (bpm_i * WINDOW_SECONDS * windows + 59) / 60;

      $display("[TB] Driving %0d BPM for %0d window(s): ticks/beat=%0d, beats=%0d",
              bpm_i, windows, ticks, beats);

      // Wait one clock after reset releases, then start
      @(posedge clk);

      for (k = 0; k < beats; k = k + 1) begin
        // Wait for next beat time (leave room for pulse width)
        repeat (ticks - PULSE_W) @(posedge clk);
        // Make a WIDER pulse so it’s visible
        pulse_in <= 1'b1;
        repeat (PULSE_W) @(posedge clk);
        pulse_in <= 1'b0;
      end
    end
  endtask


  // Main Test Sequence
  initial begin
    $dumpfile("heartbeat_counter.vcd");
    $dumpvars(0, heartbeat_counter_tb);

    repeat (10) @(posedge clk);
    reset <= 1'b0;  // release reset and begin operation


    // Test 1: 60 BPM for 1 window    
    fork
      drive_bpm(60, 1);  // generate ~60 BPM for 1 window
      begin
        @(posedge new_bpm); // wait until DUT says "BPM updated"
        $display("[T=%0t] Measured BPM = %0d (expect ~60)", $time, bpm);
      end
    join

    
    // Test 2: 90 BPM for 1 window
    fork
      drive_bpm(90, 1);
      begin
        @(posedge new_bpm);
        $display("[T=%0t] Measured BPM = %0d (expect ~90)", $time, bpm);
      end
    join

    // Test 3: 120 BPM for 1 window
    fork
      drive_bpm(120, 1);
      begin
        @(posedge new_bpm);
        $display("[T=%0t] Measured BPM = %0d (expect ~120)", $time, bpm);
      end
    join

    // End simulation
    #100_000;
    $finish;
  end

endmodule
