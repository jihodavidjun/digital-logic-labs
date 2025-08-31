`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// mini_riscv.v
// A super-small RISC-V RV32I core that implements a subset of the base integer ISA. 
//
// Supported instructions:
//   - R-type: ADD, SUB, AND, OR
//   - I-type: ADDI
//   - B-type: BEQ
//
// Microarchitecture:
//   - Single-cycle per pipeline stage with a tiny 3-state FSM: FETCH -> EXEC -> WB (write-back) -> FETCH ...
//   - Instruction memory is a simple array inside this module. The testbench preloads it by hierarchical reference.
//   - Register file is 32 x 32-bit. x0 is hard-wired to 0.
//   - Program Counter (PC) is byte-addressed and increments by 4 (word aligned).
// -----------------------------------------------------------------------------

module mini_riscv #(parameter IMEM_WORDS = 64)
(input wire clk,
 input wire reset);

reg [31:0] pc;       
reg [31:0] next_pc;  

reg [31:0] imem [0:IMEM_WORDS-1]; // 64
wire [31:0] instr = imem[pc[31:2]]; // divide by 4; 2^2 = 4

reg [31:0] regs [0:31];

// DECODE FIELDS
wire [6:0] opcode = instr[6:0]; // instruction
wire [4:0] rd = instr[11:7]; // destination register index
wire [2:0] funct3 = instr[14:12]; // sub-op selector
wire [4:0] rs1 = instr[19:15]; // source register 1 index
wire [4:0] rs2 = instr[24:20]; // source register 2 index
wire [6:0] funct7 = instr[31:25]; // additional sub-op selector

// READ OPERANDS FROM REG. FILE
wire [31:0] rs1_val = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
wire [31:0] rs2_val = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

// IMMEDIATE GENERATOR
// - I-type immediate (for ADDI): bits [31:20], sign-extended.
// - B-type immediate (for BEQ): scattered fields, then <<1, sign-extended.

wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]}; // 32-20 = 12
wire [31:0] imm_b = {{19{instr[31]}}, // sign bits
                       instr[31], // imm[12]
                       instr[7], // imm[11]
                       instr[30:25], // imm[10:5]
                       instr[11:8], // imm[4:1]
                       1'b0}; // imm[0] = 0 


// ALU (ADD/SUB/AND/OR + ADDI)
reg [31:0] alu_y;

  always @* begin
    alu_y = 32'd0; 
    case (opcode)
      7'h33: begin // R-type
        case ({funct7, funct3})
          {7'h00, 3'b000}: alu_y = rs1_val + rs2_val; // ADD
          {7'h20, 3'b000}: alu_y = rs1_val - rs2_val; // SUB (funct7=0x20)
          {7'h00, 3'b110}: alu_y = rs1_val | rs2_val; // OR
          {7'h00, 3'b111}: alu_y = rs1_val & rs2_val; // AND
          default: alu_y = 32'd0;  
        endcase
      end

      7'h13: begin // I-type
        if (funct3 == 3'b000) // just re-confirming
          alu_y = rs1_val + imm_i; // ADDI
      end

      default: alu_y = 32'd0;  
    endcase
  end

// NEXT-PC + WRITEBACK CONTROL
reg do_write; // write-back enable
reg [31:0] wb_data; // data that will be written to 'rd' in WB state

always @* begin
    do_write = 1'b0;
    wb_data = 32'd0;
    next_pc = pc + 32'd4;

    case (opcode)
      7'h33: begin // R-type
        do_write = (rd != 5'd0); // never write x0
        wb_data = alu_y; // result from ALU
      end

      7'h13: begin // I-type
        do_write = (rd != 5'd0);
        wb_data = alu_y; // rs1 + imm_i from ALU
      end

      7'h63: begin // B-type
        if (funct3 == 3'b000) begin 
          if (rs1_val == rs2_val)
            next_pc = pc + imm_b; // take the branch
        end
      end

      default: ; 
    endcase
  end

  // CONTROL FSM: FETCH -> EXEC -> WB (repeat)
  // - FETCH: 'instr' is read from imem using current 'pc'
  // - EXEC: ALU/branch/next_pc/wb decisions are resolved
  // - WB: commit register write and update PC
  localparam FETCH = 2'd0,
             EXEC = 2'd1,
             WB = 2'd2;

  reg [1:0] state;  

  always @(posedge clk) begin
    if (reset) begin
      pc <= 32'd0;
      state <= FETCH;
    end

    else begin
      case (state)
        FETCH: begin
          state <= EXEC;
        end

        EXEC: begin
          state <= WB;
        end

        WB: begin
          // 1) Register writeback (if enabled and not x0)
          if (do_write && (rd != 5'd0))
            regs[rd] <= wb_data;

          // 2) Update the program counter
          pc <= next_pc;

          // 3) Next instruction
          state <= FETCH;
        end

        default: state <= FETCH; 
      endcase
    end
  end

  // Keep x0 hard-wired to zero 
  always @(posedge clk) begin
    if (!reset) regs[0] <= 32'd0;
  end

endmodule