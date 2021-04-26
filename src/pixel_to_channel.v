module pixel_to_channel(
    channel_enable,         // input ---> Array with channel enable signals (needed to calculate height per channel)
    pixel_row,              // input ---> Pixel row of which to get the channel
    is_channel,             // output --> Belongs pixel row to a channel?
    channel_number          // output --> Channel number based on pixel row
);

// === Included headers =======================================

`include "vga.h"

// === Parameters =============================================

parameter MAX_CHAN_COUNT = 10;
parameter OFFSET = 0;

// === Module IO ==============================================

input [MAX_CHAN_COUNT-1:0] channel_enable;
input [$clog2(VGA_VER_RES)-1:0] pixel_row;

output is_channel;
output [$clog2(MAX_CHAN_COUNT)-1:0] channel_number;

// === Internal signals =======================================

reg [$clog2(MAX_CHAN_COUNT)-1:0] channel_count;

wire [$clog2(VGA_VER_RES)-1:0] channel_lower_boundary, channel_height;

// === Structure ==============================================

// Determine if the pixel belongs to a channel
assign is_channel = pixel_row > OFFSET && channel_count != 0 && channel_number < channel_count;

// Count the number of enabled channels
integer i;
always @(channel_enable) begin
    channel_count = 0;
    for(i=0; i<MAX_CHAN_COUNT; i=i+1) begin
        channel_count = channel_count + channel_enable[i];
    end
end

// Determine the height per channel
assign channel_height = (VGA_VER_RES - OFFSET)/channel_count;

// Determine channel number
assign channel_number = (pixel_row - OFFSET)/channel_height;    // FIXME: This outputs the Nth visible channel instead of the correct channel_number

endmodule