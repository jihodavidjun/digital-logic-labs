`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// mini_riscv_tb.v
// Testbench for the tiny RISC-V core. 
//   - Generates clock/reset
//   - Preloads a tiny program directly into dut.imem[]
//   - Provides helpers to assemble instructions (R/I/B types)
//   - Lets the program run and then prints register values
//   - Dumps a VCD file for waveform viewing
// -----------------------------------------------------------------------------

module mini_riscv_tb;
  reg clk = 1'b0; 
  reg reset = 1'b1;   

  // Period 100 ns (toggle every 50 ns)
  always #50 clk = ~clk;

  // Instantiate the CPU
  mini_riscv #(.IMEM_WORDS(64)) dut (
    .clk (clk),
    .reset (reset)
  );

  initial begin
    $dumpfile("mini_riscv.vcd");
    $dumpvars(0, mini_riscv_tb);
  end

  // R-type encoder: instr[31:25]=funct7, [24:20]=rs2, [19:15]=rs1, [14:12]=funct3, [11:7]=rd, [6:0]=opcode
  function [31:0] R;
    input [6:0] funct7;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
    begin
      R = {funct7, rs2, rs1, funct3, rd, opcode};
    end
  endfunction


  // I-type encoder: instr[31:20]=imm[11:0], [19:15]=rs1, [14:12]=funct3, [11:7]=rd, [6:0]=opcode
  // 'imm' is sign-extended by the DUT.
  function [31:0] I;
    input [11:0] imm;
    input [4:0]  rs1;
    input [2:0]  funct3;
    input [4:0]  rd;
    input [6:0]  opcode;
    begin
      I = {imm, rs1, funct3, rd, opcode}; // exact packing
    end
  endfunction
  // B-type encoder: instr[31]=imm[12], instr[30:25]=imm[10:5], instr[11:8]=imm[4:1], instr[7]=imm[11], instr[0]=0 
  //'imm' here is a byte offset (signed, multiple of 2). Assume caller provides an even offset; the LSB becomes 0 inside the packed instruction.
  function [31:0] B;
    input [12:0] imm; // 13-bit signed branch offset in BYTES (must be even)
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;
    reg [12:0] off; // local copy
    begin
      off = imm;
      B = { off[12],           // instr[31] imm[12]
            off[10:5],         // instr[30:25] imm[10:5]
            rs2,               // instr[24:20]
            rs1,               // instr[19:15]
            funct3,            // instr[14:12]
            off[4:1],          // instr[11:8] imm[4:1]
            off[11],           // instr[7] imm[11]
            opcode };          // instr[6:0]
    end
  endfunction

// Readable "macros" for the subset 
`define OPC_R 7'h33
`define OPC_I 7'h13
`define OPC_B 7'h63

`define ADD(rd,rs1,rs2) R(7'h00, rs2, rs1, 3'b000, rd, `OPC_R)
`define SUB(rd,rs1,rs2) R(7'h20, rs2, rs1, 3'b000, rd, `OPC_R) 
`define OR_(rd,rs1,rs2) R(7'h00, rs2, rs1, 3'b110, rd, `OPC_R)
`define AND(rd,rs1,rs2) R(7'h00, rs2, rs1, 3'b111, rd, `OPC_R)

`define ADDI(rd,rs1,imm) I(imm, rs1, 3'b000, rd, `OPC_I)

`define BEQ(rs1,rs2,imm_bytes) B(imm_bytes, rs2, rs1, 3'b000, `OPC_B)

// TEST
 integer k;

  initial begin
    repeat (5) @(posedge clk);
    reset <= 1'b0;

    // pc = 0x00: x1 = 5
    dut.imem[0] = `ADDI(5'd1, 5'd0, 12'd5);

    // pc = 0x04: x2 = 7
    dut.imem[1] = `ADDI(5'd2, 5'd0, 12'd7);

    // pc = 0x08: x3 = x1 + x2 (=12)
    dut.imem[2] = `ADD(5'd3, 5'd1, 5'd2);

    // pc = 0x0C: x4 = x2 - x1 (=2)
    dut.imem[3] = `SUB(5'd4, 5'd2, 5'd1);

    // pc = 0x10: x5 = x1 & x2 (=5)
    dut.imem[4] = `AND(5'd5, 5'd1, 5'd2);

    // pc = 0x14: x6 = x1 | x2 (=7)
    dut.imem[5] = `OR_(5'd6, 5'd1, 5'd2);

    // pc = 0x18: if (x0==x0) branch +8 bytes -> skip next instruction (at 0x1C) and land at 0x20
    // BEQ offset is a byte offset. Skip exactly one 4-byte instruction, but because of the simple 3-state FSM timing, +8 ensures a clean jump.
    dut.imem[6] = `BEQ(5'd0, 5'd0, 13'd8);

    // pc = 0x1C: x7 = 99 (should be skipped due to BEQ)
    dut.imem[7] = `ADDI(5'd7, 5'd0, 12'd99);

    // pc = 0x20: x7 = 11 (should execute)
    dut.imem[8] = `ADDI(5'd7, 5'd0, 12'd11);

    repeat (60) @(posedge clk);

    // Print out the register values of interest.
    $display("x3=%0d (expect 12), x4=%0d (expect 2), x5=%0d (expect 5), x6=%0d (expect 7), x7=%0d (expect 11)",
             dut.regs[3], dut.regs[4], dut.regs[5], dut.regs[6], dut.regs[7]);

<<<<<<< HEAD:04: Mini RISC-V/mini_riscv_tb.v
    // Pass/fail prints
=======
    // Immediate assertions
>>>>>>> 85af160 (Update TB.):04: Mini RISC-V/mini_riscv_tb.sv
    assert (dut.regs[3] === 32'd12) else $fatal("x3 wrong: %0d", dut.regs[3]);
    assert (dut.regs[4] === 32'd2 ) else $fatal("x4 wrong: %0d", dut.regs[4]);
    assert (dut.regs[5] === 32'd5 ) else $fatal("x5 wrong: %0d", dut.regs[5]);
    assert (dut.regs[6] === 32'd7 ) else $fatal("x6 wrong: %0d", dut.regs[6]);
    assert (dut.regs[7] === 32'd11) else $fatal("x7 wrong: %0d", dut.regs[7]);
<<<<<<< HEAD:04: Mini RISC-V/mini_riscv_tb.v
    
=======

>>>>>>> 85af160 (Update TB.):04: Mini RISC-V/mini_riscv_tb.sv
    #200 $finish;
  end

endmodule
