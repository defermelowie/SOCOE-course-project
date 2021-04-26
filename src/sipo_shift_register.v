module sipo_shift_register (
    clk,
    reset,
    s_in,
    p_out
);

// === Parameters =============================================

parameter SIZE = 256;

// === Module IO ==============================================

input clk;
input reset;
input s_in;
output reg [SIZE-1:0] p_out;

// === Structure ==============================================

always @(posedge clk or posedge reset) begin
    if (reset)
        p_out = 0;
    else begin
        p_out = p_out << 1;
        p_out[0] = s_in;
    end
end
    
endmodule