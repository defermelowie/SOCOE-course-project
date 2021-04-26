module sipo_shift_register (
    clk,    // input ---> clock
    reset,  // input ---> asynchronous reset
    shift,  // input ---> shift now?
    s_in,   // input ---> serial input
    p_out   // output --> parallel output
);

// === Parameters =============================================

parameter SIZE = 256;

// === Module IO ==============================================

input clk, reset, shift, s_in;
output reg [SIZE-1:0] p_out;

// === Structure ==============================================

// INFO: only for testing
initial begin
    p_out = 256'h1578785477887da7844557a78545e784ff785487e1578785477887da784455ad;
end

always @(posedge clk or posedge reset) begin
    if (reset)
        p_out = 0;
    else if (shift) begin
        p_out = p_out << 1;
        p_out[0] = s_in;
    end
end
    
endmodule