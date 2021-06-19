module logic_analyzer (
    clk,          // input ---> clock
    reset,        // input ---> asynchronous reset
    chan_enable,  // input ---> array with an enable for each channel
    chan_in,      // input ---> input signal of each channel
    trig_enable,  // input ---> enable triggering (data reading)
    vga_r,        // output --> vga red signal
    vga_g,        // output --> vga green signal
    vga_b,        // output --> vga blue signal
    vga_hsync,    // output --> vga horizontal sync
    vga_vsync     // output --> vga vertical sync
);

// === Included headers =======================================

`include "config.h"
`include "vga.h"

// === Parameters =============================================

parameter CHANNEL_COUNT = 10;
parameter CLOCK_FREQ = 50_000_000;

// === Module IO ==============================================

input clk;
input reset;
input [CHANNEL_COUNT-1:0] chan_enable;
input [CHANNEL_COUNT-1:0] chan_in;
input trig_enable;
output reg [VGA_COLOR_DEPTH-1:0] vga_r;
output reg [VGA_COLOR_DEPTH-1:0] vga_g;
output reg [VGA_COLOR_DEPTH-1:0] vga_b;
output vga_hsync;
output vga_vsync;

// === Internal signals =======================================

// VGA signals
wire [$clog2(VGA_HOR_TOTAL)-1:0] vga_display_col;
wire [$clog2(VGA_HOR_TOTAL)-1:0] vga_display_next_col;
wire [$clog2(VGA_VER_TOTAL)-1:0] vga_display_row;
wire [$clog2(VGA_VER_TOTAL)-1:0] vga_display_next_row;
wire vga_visible;
wire vga_visible_next;

// Display layout signals
wire is_channel_pixel;
wire is_header_pixel = vga_display_row >= 0 && vga_display_row < HEADER_SIZE;

// Channel layout signals
wire [$clog2(CHANNEL_COUNT)-1:0] current_channel;
wire [$clog2(VGA_VER_TOTAL)-1:0] current_channel_height, current_channel_offset;
wire [$clog2(VGA_VER_TOTAL)-1:0] current_channel_pxl_row = vga_display_row - current_channel_offset;
wire current_channel_pixel_status;

// Data
// SOURCE: https://www.chipverify.com/verilog/verilog-arrays-memories
wire [SAMPLE_BUFF_SIZE-1:0] channel_data [CHANNEL_COUNT-1:0];
wire [SAMPLE_BUFF_SIZE-1:0] current_channel_data = channel_data[current_channel];
reg [31:0] trigger_counter; // Trigger (chan_in) when this counter reaches predefined value
wire trigger = (trigger_counter == TRIGGER_VAL) && trig_enable;


wire pixelout;
wire [14:0] fontaddress; // address to the 32K x 1 font ROM
wire [3:0] f_pixel_hor; // horizontal pixel address in 16x16 font
wire [3:0] f_pixel_ver; // vertical pixel address in 16x16 font
wire [6:0] char_col; // column number of a character
wire char_row; // row number of a character
wire [6:0] fontrom_address;
wire [7:0] index;
wire [0:36] channel_enable_extended;
assign index = {char_row, char_col};

assign f_pixel_hor = vga_display_col[3:0];
assign f_pixel_ver = vga_display_row[3:0];
assign char_col = vga_display_col[10:4];
assign char_row = vga_display_row[4];

assign fontaddress = {fontrom_address, f_pixel_ver, f_pixel_hor};

assign channel_enable_extended = {chan_enable[0], 3'b111, chan_enable[1], 3'b111, chan_enable[2], 3'b111, chan_enable[3], 3'b111, chan_enable[4], 3'b111, chan_enable[5], 3'b111, chan_enable[6], 3'b111, chan_enable[7], 3'b111, chan_enable[8], 3'b111, chan_enable[9]};

// === Used modules ===========================================

vga_timing_generator vga_tg (
    .clk(clk),
    .reset(reset),
    .display_col(vga_display_col),
    .display_row(vga_display_row),
    .display_next_col(vga_display_next_col),
    .display_next_row(vga_display_next_row),
    .visible(vga_visible),
    .visible_next(vga_visible_next),
    .hsync(vga_hsync),
    .vsync(vga_vsync)
);

pixel_to_channel #(
    .MAX_CHAN_COUNT(CHANNEL_COUNT),
    .OFFSET(HEADER_SIZE)
) ptc (
    .channel_enable(chan_enable),
    .pixel_row(vga_display_row),
    .is_channel(is_channel_pixel),
    .channel_number(current_channel),
    .channel_height(current_channel_height),     
    .channel_offset(current_channel_offset)
);

data_to_pixelstatus #(
    .DATA_SIZE(SAMPLE_BUFF_SIZE),
    .TRACE_OFFSET(16)
) dtps (
    .data(current_channel_data),
	 .max_height(current_channel_height),
    .pxl_row(current_channel_pxl_row),
    .pxl_col(vga_display_col),
    .pxl_status(current_channel_pixel_status)
);

// SOURCE: https://www.chipverify.com/verilog/verilog-generate-block
// SOURCE: https://stackoverflow.com/questions/33899691/instantiate-modules-in-generate-for-loop-in-verilog/33900079
genvar i;
generate
    for(i = 0; i < CHANNEL_COUNT; i = i + 1) begin : sipo_gen
        sipo_shift_register #(
            .SIZE(SAMPLE_BUFF_SIZE)
        ) sipo_reg (
            .clk(clk),
            .reset(reset),
            .shift(trigger),
            .s_in(chan_in[i]),
            .p_out(channel_data[i])
        );
    end
endgenerate




fontrom fontrom(
	 .address(fontaddress),
	 .clock(clk),
	 .data('b0),
	 .wren(1'b0),
	 .q(pixelout)
	 );
	 
header_buffer textram(
	 .address(index),
	 .clock(clk),
	 .data('b0),
	 .wren(1'b0),
	 .q(fontrom_address)
	 );

// === Structure ==============================================

// Trigger counter (read new data when trigger_counter reaches a predefined value)
always @(posedge clk or posedge reset) begin
    if (reset)
        trigger_counter = 0;
    else begin
        if (trigger || ~trig_enable)    // If triggered previous clock cycle, reset counter. Otherwise count up
            trigger_counter = 0;
        else
            trigger_counter = trigger_counter + 1;
    end
end

// VGA pixel color determinator
always @(posedge clk or posedge reset) begin
    if (reset) begin
        vga_r = 0;
        vga_g = 0;
        vga_b = 0;
    end else begin
        if (vga_visible) 
            if (is_channel_pixel) begin
                // Set channel pixels
                vga_r = (current_channel_pixel_status) ? SIGNAL_COLOR[23:23 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
                vga_g = (current_channel_pixel_status) ? SIGNAL_COLOR[15:15 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
                vga_b = (current_channel_pixel_status) ? SIGNAL_COLOR[07:07 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
            end else if (is_header_pixel) begin
					 //Set header pixels
					 if (pixelout) begin
							//Determine if it is a channel number
							if (char_row && char_col > 18) begin
								 if (channel_enable_extended[char_col-19]) begin
									vga_r = TEXT_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
									vga_g = TEXT_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
									vga_b = TEXT_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
								 end else begin
									vga_r = BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
									vga_g = BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
									vga_b = BACKGROUND_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
								 end
							end else begin
								vga_r = TEXT_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
								vga_g = TEXT_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
								vga_b = TEXT_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
							end
					 end else begin
							vga_r = BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
							vga_g = BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
							vga_b = BACKGROUND_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
					 end 					 
            end else begin
                vga_r = BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
                vga_g = BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
                vga_b = BACKGROUND_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
            end
        else begin
            vga_r = 0;
            vga_g = 0;
            vga_b = 0;
        end
    end
end


endmodule