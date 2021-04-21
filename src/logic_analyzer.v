module logic_analyzer (
    clk,          // input ---> clock
    reset,        // input ---> asynchronous reset
    chan_enable   // input ---> array with an enable for each channel
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

parameter COLOR_DEPTH = 4;

// === Module IO ==============================================

input clk;
input reset;
input [9:0] chan_enable;
output [COLOR_DEPTH-1:0] vga_r;
output [COLOR_DEPTH-1:0] vga_g;
output [COLOR_DEPTH-1:0] vga_b;
output vga_hsync;
output vga_vsync;

// === Internal signals =======================================

// VGA signals
wire [11:0] vga_display_col;    // TODO: Set correct length which is $clog2(VGA_HOR_TOTAL)
wire [11:0] vga_display_next_col;    // TODO: Set correct length which is $clog2(VGA_HOR_TOTAL)
wire [10:0] vga_display_row;    // TODO: Set correct length which is $clog2(VGA_VER_TOTAL)
wire [10:0] vga_display_next_row;    // TODO: Set correct length which is $clog2(VGA_VER_TOTAL)
wire vga_visible;
wire vga_visible_next;

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

// === Structure ==============================================


endmodule