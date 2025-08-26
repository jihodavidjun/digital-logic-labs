module counter (
    input wire clk,  
    input wire reset, // synchronous reset
    output reg [3:0] q 
);
    always @(posedge clk) begin
        if (reset)         
            q <= 4'd0;
        else             
            q <= q + 4'd1; // increment and wrap naturally at 4 bits
    end
endmodule