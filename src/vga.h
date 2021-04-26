//==============================================================================//
//                      This file contains vga parameters                       //
//==============================================================================//

`define VGA_H

// === Resolution =============================================
//
// NOTE: The required clock must be configured via a pll
//
// Available resolutions:
//  _________________________________
// |Resolution      | Required clock |
// |----------------|----------------|
// |r800x600_60Hz   | 50 MHz         |
// |r1280x1024_60Hz | 108 MHz        |
// |r1440x900_60Hz  | 106.47 MHz     |
// |----------------|----------------|

`define r1440x900_60Hz // WARNING: This does not ensure the correct clock frequency

// === Color depth ============================================

parameter VGA_COLOR_DEPTH = 4;

// === Resolution definitions =================================

`ifdef  r800x600_60Hz
    parameter VGA_CLOCK_FREQ = 50e6;
    parameter VGA_HOR_RES = 800;
    parameter VGA_VER_RES = 600;
    parameter VGA_HOR_FIELD = 799;
    parameter VGA_HOR_STR_SYNC = 855;
    parameter VGA_HOR_STP_SYNC = 978;
    parameter VGA_HOR_TOTAL = 1042;
    parameter VGA_VER_FIELD = 599;
    parameter VGA_VER_STR_SYNC = 636;
    parameter VGA_VER_STP_SYNC = 642;
    parameter VGA_VER_TOTAL = 665;
`elsif r1280x1024_60Hz
    parameter VGA_CLOCK_FREQ = 108e6;
    parameter VGA_HOR_RES = 1280;
    parameter VGA_VER_RES = 1024;
    parameter VGA_HOR_FIELD = 1279;
    parameter VGA_HOR_STR_SYNC = 1327;
    parameter VGA_HOR_STP_SYNC = 1439;
    parameter VGA_HOR_TOTAL = 1687;
    parameter VGA_VER_FIELD = 1023;
    parameter VGA_VER_STR_SYNC = 1024;
    parameter VGA_VER_STP_SYNC = 1027;
    parameter VGA_VER_TOTAL = 1065;
`elsif r1440x900_60Hz
    parameter VGA_CLOCK_FREQ = 106.47e6;
    parameter VGA_HOR_RES = 1440;
    parameter VGA_VER_RES = 900;
    parameter VGA_HOR_FIELD = 1439;
    parameter VGA_HOR_STR_SYNC = 1519;
    parameter VGA_HOR_STP_SYNC = 1671;
    parameter VGA_HOR_TOTAL = 1903;
    parameter VGA_VER_FIELD = 899;
    parameter VGA_VER_STR_SYNC = 900;
    parameter VGA_VER_STP_SYNC = 903;
    parameter VGA_VER_TOTAL = 931;
`endif
