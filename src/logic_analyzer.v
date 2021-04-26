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
wire [11:0] vga_display_col;         // TODO: Set correct length which is $clog2(VGA_HOR_TOTAL)
wire [11:0] vga_display_next_col;    // TODO: Set correct length which is $clog2(VGA_HOR_TOTAL)
wire [10:0] vga_display_row;         // TODO: Set correct length which is $clog2(VGA_VER_TOTAL)
wire [10:0] vga_display_next_row;    // TODO: Set correct length which is $clog2(VGA_VER_TOTAL)
wire vga_visible;
wire vga_visible_next;

// Display layout signals
wire [$clog2(CHANNEL_COUNT)-1:0] current_channel;
wire is_channel_pixel;

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
    .OFFSET(64)  // TODO: Make header size configurable in config.h
) (
    .channel_enable(chan_enable),
    .pixel_row(vga_display_row),
    .is_channel(is_channel_pixel),
    .channel_number(current_channel)
);

// === Structure ==============================================

// INFO: this is only to test if vga works
integer j;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        vga_r = 0;
        vga_g = 0;
        vga_b = 0;
    end else begin
        if (vga_visible) 
            if (is_channel_pixel) begin
                vga_r = SIGNAL_COLOR[23:23 - (VGA_COLOR_DEPTH-1)] - current_channel;
                vga_g = SIGNAL_COLOR[15:15 - (VGA_COLOR_DEPTH-1)] - current_channel;
                vga_b = SIGNAL_COLOR[7:7 - (VGA_COLOR_DEPTH-1)] - current_channel;
            end else begin
                vga_r = BACKGROUND_COLOR[23:23 - (VGA_COLOR_DEPTH-1)];
                vga_g = BACKGROUND_COLOR[15:15 - (VGA_COLOR_DEPTH-1)];
                vga_b = BACKGROUND_COLOR[7:7 - (VGA_COLOR_DEPTH-1)];
            end
        else begin
            vga_r = 0;
            vga_g = 0;
            vga_b = 0;
        end
    end
end


endmodule