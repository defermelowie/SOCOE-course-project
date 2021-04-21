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

// === Resolution =============================================

// Available resolutions (defined in vga.h):
//
// |Resolution     | VGA clock   |
// |---------------|-------------|
// |800x600_60Hz   | 50 MHz      |
// |1280x1024_60Hz | 108 MHz     |
// |1440x900_60Hz  | 106.47 MHz  |

`define 1440x900_60Hz
