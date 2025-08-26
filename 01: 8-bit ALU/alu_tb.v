// alu_tb.v — testbench for alu.v
`timescale 1ns/1ps

module alu_tb;
    reg [7:0] a, b;
    reg [2:0] op;
    wire [7:0] result;
    wire carry_out, zero;

    // Device Under Test
    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .carry_out(carry_out),
        .zero(zero)
    );

    task show;
        begin
            $display("t=%0t  op=%b  a=%0d  b=%0d  ->  res=%0d(0x%0h)  c=%b  z=%b",
                     $time, op, a, b, result, result, carry_out, zero); // %0t = simulation time, %b = binary, %d = decimal, %h = hex
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // initializing
        a = 0; b = 0; op = 3'b000; #5; // wait 5 ns so that values settle

        // Tests
        // ADD
        op=3'b000; a=8'd10; b=8'd5; #5; show(); // 10+5 = 15, carry=0
        op=3'b000; a=8'd200; b=8'd100; #5; show(); // 200+100 = 300 -> wraps to 44, carry=1

        // SUB
        op=3'b001; a=8'd10; b=8'd5; #5; show(); // 10-5=5, carry_out=1 (borrow)
        op=3'b001; a=8'd5; b=8'd10; #5; show(); // 5-10=two's comp 251, carry_out=0 (no borrow)

        // AND / OR / XOR
        op=3'b010; a=8'b10101010; b=8'b11001100; #5; show(); // both 1: 10001000
        op=3'b011; a=8'b10101010; b=8'b11001100; #5; show(); // either 1: 11101110
        op=3'b100; a=8'b10101010; b=8'b11001100; #5; show(); // one 1: 01100110

        // zero flag check
        op=3'b010; a=8'hF0; b=8'h0F; #5; show();

        $display("ALU TB finished.");
        $finish;
    end
endmodule