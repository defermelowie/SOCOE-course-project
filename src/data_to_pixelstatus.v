module data_to_pixelstatus (
           data,       // input ---> data of the channel
           max_height, // input ---> height in pixels of the channel
           pxl_row,    // input ---> row of the pixel
           pxl_col,    // input ---> column of th pixel
           pxl_status  // output --> status of the pixel: 1 = on, 0 = off
       );

// === Included headers =======================================

`include "vga.h"

// === Parameters =============================================

parameter DATA_SIZE = 256;
parameter TRACE_OFFSET = 8;
parameter TRACE_THICKNESS = 2;

// === Module IO ==============================================

input [DATA_SIZE-1:0] data;
input [$clog2(VGA_VER_TOTAL)-1:0] max_height, pxl_row;
input [$clog2(VGA_HOR_TOTAL)-1:0] pxl_col;

output pxl_status;

// === Internal signals =======================================

wire data_at_curr_pxl_col = data[pxl_col*DATA_SIZE/VGA_HOR_RES]; // FIXME: Devision is extremely costly, is there a better way?

wire [$clog2(VGA_HOR_TOTAL)-1:0] prev_pxl_col = pxl_col-1;
wire data_at_prev_pxl_col = data[prev_pxl_col*DATA_SIZE/VGA_HOR_RES]; // FIXME: Devision is extremely costly, is there a better way?
wire data_change = data_at_curr_pxl_col != data_at_prev_pxl_col;

wire pxl_data_high_status = (pxl_row > TRACE_OFFSET-1) && (pxl_row < TRACE_OFFSET + TRACE_THICKNESS);
wire pxl_data_low_status = (pxl_row < max_height) && (pxl_row >= max_height - TRACE_THICKNESS);
wire pxl_data_change_status = (pxl_row > TRACE_OFFSET-1) && (pxl_row < max_height);

// === Structure ==============================================

assign pxl_status = ((data_at_curr_pxl_col) ? pxl_data_high_status : pxl_data_low_status) || (data_change && pxl_data_change_status);

endmodule
