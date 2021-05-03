module pixel_to_channel(
    channel_enable,         // input ---> Array with channel enable signals (needed to calculate height per channel)
    pixel_row,              // input ---> Pixel row of which to get the channel
    is_channel,             // output --> Belongs pixel row to a channel?
    channel_number,         // output --> Channel number based on pixel row
    channel_height,         // output --> height of the channel in pixels
    channel_offset          // output --> channel vertical offset
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
output reg [$clog2(MAX_CHAN_COUNT)-1:0] channel_number;
output [$clog2(VGA_VER_RES)-1:0] channel_height, channel_offset;

// === Internal signals =======================================

reg [$clog2(MAX_CHAN_COUNT)-1:0] channel_count;
wire [$clog2(MAX_CHAN_COUNT)-1:0] visible_channel_number;

// === Structure ==============================================

// Determine if the pixel belongs to a channel
assign is_channel = pixel_row >= OFFSET && channel_count != 0 && visible_channel_number < channel_count;

// Count the number of enabled channels
integer i;
always @(*) begin
    channel_count = 0;
    for(i=0; i<MAX_CHAN_COUNT; i=i+1) begin
        channel_count = channel_count + channel_enable[i];
    end
end

// Determine the height per channel
assign channel_height = (VGA_VER_RES - OFFSET)/channel_count; // FIXME: Devision is extremely costly, is there a better way?

// Determine which visible channel this is
assign visible_channel_number = ((pixel_row - OFFSET) / (VGA_VER_RES - OFFSET)) * channel_count; // FIXME: Devision is extremely costly, is there a better way?

// Determine channel vertical offset
assign channel_offset = OFFSET + (channel_height * visible_channel_number);

// Map visible channel number to channel number
//
// Example (channel enable = 'b100101):
// nth visible channel -> nth one is kth bit -> kth channel
// 0 -------------------> 1 ------------------> 0
//                        0
// 1 -------------------> 1 ------------------> 2
//                        0
//                        0
// 2 -------------------> 1 ------------------> 5
// TODO: Ask Luc if there is a better way to map this since this one is ugly
integer k, n;
reg [$clog2(MAX_CHAN_COUNT)-1:0] count;
always @(*) begin
    n = 0;
    channel_number = 0;
    for(k=0; k<MAX_CHAN_COUNT; k=k+1) begin
        if (channel_enable[k] && n == visible_channel_number)
            channel_number = k;
        n = n + channel_enable[k];
    end
end

endmodule