module logic_analyzer (
    clk,          // input ---> clock
    reset,        // input ---> asynchronous reset
    chan_enable,  // input ---> array with an enable for each channel
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

// === Module IO ==============================================

input clk;
input reset;
input [CHANNEL_COUNT-1:0] chan_enable;
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
wire [$clog2(CHANNEL_COUNT)-1:0] current_channel;
wire is_channel_pixel;
wire is_header_pixel = vga_display_row >= 0 && vga_display_row < HEADER_SIZE;

// Data
wire [SAMPLE_BUFF_SIZE-1:0] channel_data [CHANNEL_COUNT-1:0];   // FIXME: Data from sipo regs does not appear here

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
    .channel_number(current_channel)
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
            .shift(1'b0),   // TODO: Shift when reading new data
            .s_in(1'b0),    // TODO: Read new data
            .p_out(channel_data[i][SAMPLE_BUFF_SIZE-1:0])   // FIXME: Data from sipo regs does not appear in channel_data
        );
    end
endgenerate

// === Structure ==============================================

// VGA pixel color determinator
always @(posedge clk or posedge reset) begin
    if (reset) begin
        vga_r = 0;
        vga_g = 0;
        vga_b = 0;
    end else begin
        if (vga_visible) 
            if (is_channel_pixel) begin
                // TODO: Set channel pixels
                vga_r = (current_channel[0] && vga_display_col[3]) ? SIGNAL_COLOR[23:23 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
                vga_g = (current_channel[0] && vga_display_col[3]) ? SIGNAL_COLOR[15:15 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
                vga_b = (current_channel[0] && vga_display_col[3]) ? SIGNAL_COLOR[07:07 - (VGA_COLOR_DEPTH-1)] : BACKGROUND_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
            end else if (is_header_pixel) begin
                // TODO: Set header pixels
                vga_r = TEXT_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
                vga_g = TEXT_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
                vga_b = TEXT_COLOR[07:07 - (VGA_COLOR_DEPTH-1)];
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