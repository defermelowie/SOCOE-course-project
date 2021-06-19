//===============================================================================//
//                 This file contains general config parameters                  //
//===============================================================================//

`define CONFIG_H

// === Colors =================================================
// Use hexadecimal color representation and write as valid verilog.
// For example: white --> #FFFFFF --> 24'hffffff

// SOURCE: https://www.nordtheme.com/
parameter SIGNAL_COLOR = 24'hA3BE8C;
parameter BACKGROUND_COLOR = 24'h2E3440;
parameter TEXT_COLOR = 24'hECEFF4;

// === Sample frequency =======================================

// TODO: Optional, make sample frequency configurable instead of counter val
// This is when the counter resets and new data is read.
parameter TRIGGER_VAL = 20_000_000;

// === Sample buffer size =====================================

parameter SAMPLE_BUFF_SIZE = 64;

// === Header size ============================================
// This is the size in pixels of the header at the top of the screen

parameter HEADER_SIZE = 32;
