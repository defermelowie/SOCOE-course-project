# Logic Analyzer

*Butaye Jonathan & Deferme Lowie*

<img src="./res/screenshot.jpg" alt="Screenshot" style="zoom:15%;" />

## Introduction

The goal of this project was to create a logic analyzer on an *Altera Max 10* FPGA, therefore development was done on a *Terasic DE10-Lite* FPGA board. Verilog was used as the hardware discription language. The output of the logic analyzer was chosen to be a VGA screen as seen in the screenshot above.

The project code is available in [this github repo](https://github.com/defermelowie/SOCOE-course-project/).

## Structure

TODO: Explain overview

![Overview of the structure](./res/structure.svg)

### Top level design file

This file sits in `./src/boardspecific` and therefore isn't present in the repo, however the folder contains a [readme](../src/boardspecific/README.md) with an example of this file.

The top level design file contains a phase locked loop (PLL) in order to provide the correct clock for the VGA display. Furthermore necessary IO's are forwarded to the `logic_analyzer` module here. 

### Logic analyzer

[`logic_analyzer`](../src/logic_analyzer.v) is the main module of this project. It uses the physical inputs to generate vga output as seen in the definition below:

```Verilog
module logic_analyzer (
    clk,          // input ---> clock
    reset,        // input ---> asynchronous reset
    chan_enable,  // input ---> array with an enable for each channel
    chan_in,      // input ---> input signal of each channel
    trig_enable,  // input ---> enable triggering (data reading)
    vga_r,        // output --> vga red signal
    vga_g,        // output --> vga green signal
    vga_b,        // output --> vga blue signal
    vga_hsync,    // output --> vga horizontal sync
    vga_vsync     // output --> vga vertical sync
);
```

TODO

### Vga timing generator

TODO

### Data to pixelstatus

[`data_to_pixelstatus`](../src/data_to_pixelstatus.v) is the module that determines if a pixel should be on or off based on its position and the channel data. The module definition is shown below:
```Verilog
module data_to_pixelstatus (
           data,       // input ---> data of the channel
           max_height, // input ---> height in pixels of the channel
           pxl_row,    // input ---> row of the pixel
           pxl_col,    // input ---> column of th pixel
           pxl_status  // output --> status of the pixel: 1 = on, 0 = off
);
```
TODO

### Pixel to channel

The [`pixel_to_channel`](../src/pixel_to_channel.v) module calculates the channel height, determines the channel number and of the pixel belongs to a channel. These outputs are derived from the current pixel row, the array with the channel enable signals and some parameters in the header files (more info below).  
The definition of the IO's of this module is shown below:
```Verilog
module pixel_to_channel(
    channel_enable,         // input ---> Array with channel enable signals (needed to calculate height per channel)
    pixel_row,              // input ---> Pixel row of which to get the channel
    is_channel,             // output --> Belongs pixel row to a channel?
    channel_number,         // output --> Channel number based on pixel row
    channel_height,         // output --> height of the channel in pixels
    channel_offset          // output --> channel vertical offset
);
```

To calculate the height of the channel height, the total available height on the the monitor needs to be divided by the total number of active channels.
The total available height is the vertical resolution of the monitor subtracted by the offset for the header info. The number of active channels can be derived from the channel_enable input.  
Because a division in hardware requires a lot of logic elements and is slow we need to avoid using it. In this module fixed point operations are used to avoid the division.  
The idea is to multiply by a number smaller than 1 to become the same result as the desired division. For example, instead of dividing a number by 5, multiply it with 0,2. In order to do this for our purpose to do the division for the channel height the available height is multiplied by 'multiply_factor'. This factor is an 11 bits precision factor between 0 and 1. The multiply factor is composed as follows:
```Verilog
//EXAMPLE the fraction 0,625
1  1/2  1/4  1/8  1/16 ...
^   ^    ^    ^    ^
0 _ 1    0    1    0   ...
```
The proces to determine the multiply factor is shown below:
```Verilog
// Count the number of enabled channels and determine the multiply factor
integer i;
always @(*) begin
    channel_count = 0;
    for(i=0; i<MAX_CHAN_COUNT; i=i+1) begin
        channel_count = channel_count + channel_enable[i];
    end
    case (channel_count)
	'b0001	:	multiply_factor = 11'b1_0000000000;  // -> 1   
	'b0010	:	multiply_factor = 11'b0_1000000000;  // -> 1/2 (0,5)
	'b0011	:	multiply_factor = 11'b0_0101010101;  // -> 1/3 (0,333007813)
	'b0100	:	multiply_factor = 11'b0_0100000000;  // -> 1/4 (0,25)
	'b0101	:	multiply_factor = 11'b0_0011001100;  // -> 1/5 (0,19921875)
	'b0110	:	multiply_factor = 11'b0_0010101010;  // -> 1/6 (0,166015625)
	'b0111	:	multiply_factor = 11'b0_0010010010;  // -> 1/7 (0,142578125)
	'b1000	:	multiply_factor = 11'b0_0010000000;  // -> 1/8 (0,125)
	'b1001	:	multiply_factor = 11'b0_0001110001;  // -> 1/9 (0,110351563)
	'b1010	:	multiply_factor = 11'b0_0001100110;  // -> 1/10 (0,099609375)
	default	:	multiply_factor = 11'b0_0000000000;  // -> 0 
   endcase
end
```
The multiply factors shown above represents the fractions 1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9 and 1/10.  
If we shift the result of the multiplication with 10 to the right we become the result of the desired division. The different 
```Verilog
// Determine the height per channel
assign channel_height = ((VGA_VER_RES - OFFSET)*multiply_factor)>>10;
```
More info about fixed point operations can be found on https://projectf.io/posts/fixed-point-numbers-in-verilog/, this is the site we used as inspiration.

### Sipo shift register

[This register](../src/sipo_shift_register.v) shifts one to the left when the `shift` input becomes `1`. Sipo is an acronym for "Serial In Parallel Out", this means that bits are read into the register in a serial fashion but the whole register is available as output.

![Sipo](./res/sipo.svg)

## Description of headers

### Config

[`config.h`](../src/config.h) contains general configuration parameters.

### VGA

[`vga.h`](../src/vga.h) defines the vga timing information.   

We included the timing parameters for the following resolutions:  
* 800x600 at 60Hz refresh rate  
* 1280x1024 at 60Hz refresh rate  
* 1440x900 at 60Hz refresh rate  
* 1920x1080 at 60Hz refresh rate  
