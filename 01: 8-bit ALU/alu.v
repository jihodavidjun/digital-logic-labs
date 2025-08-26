// Ops: 000=ADD, 001=SUB, 010=AND, 011=OR, 100=XOR
// Flags: carry_out (add/sub), zero (result==0)

module alu (
    input wire [7:0] a,       
    input wire [7:0] b,       
    input wire [2:0] op,      
    output reg [7:0] result,  
    output reg carry_out, 
    output wire zero       
);

    assign zero = (result == 8'b0);

    // Extend a and b to 9 bits for ADD and SUB to capture carry or borrow.
    wire [8:0] add_wide = {1'b0, a} + {1'b0, b};  
    wire [8:0] sub_wide = {1'b0, a} - {1'b0, b};  
  
    always @(*) begin
        result = 8'b0;
        carry_out = 1'b0;

        case (op)
            3'b000: begin // ADD
                result = add_wide[7:0]; 
                carry_out = add_wide[8]; 
            end
            3'b001: begin // SUB
                result = sub_wide[7:0];
                carry_out = sub_wide[8];
            end
            3'b010: result = a & b; // AND
            3'b011: result = a | b; // OR
            3'b100: result = a ^ b; // XOR
            default: begin
                result = 8'b0;
                carry_out = 1'b0;
            end
        endcase
    end
endmodule