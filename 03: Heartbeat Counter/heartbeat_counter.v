`timescale 1ns/1ps

module heartbeat_counter #(
  parameter integer WINDOW_CYCLES = 1000, // window length in clock cycles
  parameter integer SCALE_FACTOR  = 12 // BPM = beat_cnt * SCALE_FACTOR
)(
  input wire clk,
  input wire reset,    
  input wire pulse_in, // 1-clock pulse per detected heartbeat
  output reg [7:0] bpm, // 0 ~ 255
  output reg new_bpm   
);

  reg pulse_d;
  wire beat_pulse = pulse_in & ~pulse_d; // Stored one = 0

  reg [31:0] win_cnt; // window time counter
  reg [15:0] beat_cnt; // beats seen in the current window

  reg [1:0] state;
  parameter MEASURE = 2'd0;
  parameter UPDATE  = 2'd1;

  always @(posedge clk) begin
    if (reset) begin
      pulse_d <= 1'b0;
      win_cnt <= 32'd0;
      beat_cnt <= 16'd0;
      bpm <= 8'd0;
      new_bpm <= 1'b0;
      state <= MEASURE;
    end else begin
      pulse_d <= pulse_in;     
      new_bpm <= 1'b0; // default low, store for update

      case (state)
        MEASURE: begin
          if (beat_pulse)
            beat_cnt <= beat_cnt + 16'd1;

          win_cnt <= win_cnt + 32'd1;

          if (win_cnt == WINDOW_CYCLES-1) begin // Done window
            bpm <= beat_cnt * SCALE_FACTOR;
            new_bpm <= 1'b1;
            state <= UPDATE;
          end
        end

        UPDATE: begin
          win_cnt <= 32'd0;
          beat_cnt <= 16'd0;
          state <= MEASURE;
        end

        default: state <= MEASURE;
      endcase
    end
  end
  
endmodule
