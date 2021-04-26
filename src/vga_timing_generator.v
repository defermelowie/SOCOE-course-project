module vga_timing_generator (
    clk,                // input ---> clock signal (T_clock must match one pixel)
    reset,              // input ---> async reset signal
    display_col,        // output --> current column
    display_row,        // output --> current row
    display_next_col,   // output --> next column
    display_next_row,   // output --> next row
    visible,            // output --> is pixel at (current column, current row) visible?
    visible_next,       // output --> is pixel at (next column, next row)
    hsync,              // output --> horizontal sync
    vsync               // output --> vertical sync
);

// === Included headers =======================================

`include "vga.h"

// === Parameters =============================================

parameter HOR_SIZE = $clog2(VGA_HOR_TOTAL);
parameter VER_SIZE = $clog2(VGA_VER_TOTAL);

// === Module IO ==============================================

input clk;
input reset;
output reg [HOR_SIZE-1:0] display_col;
output reg [HOR_SIZE-1:0] display_next_col;
output reg [VER_SIZE-1:0] display_row;
output reg [VER_SIZE-1:0] display_next_row;
output reg visible;
output reg hsync, vsync;
output visible_next;


// === Internal signals =======================================

wire new_row;
wire new_screen;
wire hsync_next, vsync_next;


// === Structure ==============================================

// Check if new row/screen
assign new_row = (display_next_col == VGA_HOR_TOTAL);
assign new_screen = (display_next_row == VGA_VER_TOTAL) & new_row;

// Assign sync signals
assign hsync_next = ~((display_next_col > VGA_HOR_STR_SYNC) & (display_next_col < VGA_HOR_STP_SYNC));
assign vsync_next = ~((display_next_row > VGA_VER_STR_SYNC) & (display_next_row < VGA_VER_STP_SYNC));

// Calculate pixel visibility
assign visible_next = (display_next_col > 0) & (display_next_col < VGA_HOR_FIELD) & (display_next_row > 0) & (display_next_row < VGA_VER_FIELD);

// Calculate pixel position
always @(posedge clk or posedge reset) begin
    if (reset) begin
        display_next_col = 11'b0;
        display_next_row = 10'b0;
    end else begin
        if (new_screen) begin
            display_next_col = 11'b0;
            display_next_row = 10'b0;
        end else if (new_row) begin
            display_next_col = 11'b0;
            display_next_row = display_next_row + 10'b1;
        end else begin
            display_next_col = display_next_col + 11'b1;
        end
    end
end

// Registers
always @(posedge clk or posedge reset) begin
    if (reset) begin
        display_col = 11'b0;
        display_row = 10'b0;
        visible = 0;
        hsync = 0;
        vsync = 0;
    end else begin
        display_col = display_next_col;
        display_row = display_next_row;
        visible = visible_next;
        hsync = hsync_next;
        vsync = vsync_next;
    end
end

endmodule
