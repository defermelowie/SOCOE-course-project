module register (
    in,             // input ---> data input
    write_enable,   // input ---> write enable
    out,            // output --> data output
    clock,          // input ---> clock
    reset           // input ---> resets register
);
parameter SIZE = 1;

input [SIZE-1:0] in;
input write_enable, clock, reset;
output reg [SIZE-1:0] out;

always @(posedge clock) begin
    if (reset)
        out <= 0;
    else if (write_enable)
        out <= in;
end

endmodule