//===============================================================================//
//                 This file contains general config parameters                  //
//===============================================================================//

`define CONFIG_H

// === Colors =================================================

// Use hexadecimal color representation and write as valid verilog.
// For example #FFFFFF --> 6'hffffff

// SOURCE: https://www.nordtheme.com/
parameter SIGNAL_COLOR = 6'hA3BE8C;
parameter BACKGROUND_COLOR = 6'h2E3440;
parameter TEXT_COLOR = 6'hECEFF4;

// === Sample frequency =======================================

// TODO: Make sample frequency configurable