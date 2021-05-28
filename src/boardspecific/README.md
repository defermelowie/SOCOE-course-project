# Board specific code

Put board specific code in this directory, it will be ignored by git.

For example:

```Verilog
/=======================================================
//  REG/WIRE declarations
//=======================================================

wire reset;
assign reset = ~KEY[0];

wire clock;


//=======================================================
//  Structural coding
//=======================================================

pll_106MHz vga_pll (
	.areset(reset),
	.inclk0(MAX10_CLK1_50),
	.c0(clock)
);

logic_analyzer #(
	.CHANNEL_COUNT(10),
	.CLOCK_FREQ(106.47e6)
) la (
	.clk(clock),        
    .reset(reset),      
    .chan_enable(SW[9:0]),
	.chan_in(ARDUINO_IO[9:0]),
    .vga_r(VGA_R),      
    .vga_g(VGA_G),      
    .vga_b(VGA_B),      
    .vga_hsync(VGA_HS),  
    .vga_vsync(VGA_VS)   
);
```