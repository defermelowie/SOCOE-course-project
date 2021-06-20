# Logic Analyzer

*Butaye Jonathan & Deferme Lowie*

<img src="./res/screenshot.jpg" alt="Screenshot" style="zoom:15%;" />

## Short user guide

### Setup

First, the top level design file has to be set up, it is important to make sure that the pll is configured to the correct clock frequency the VGA monitor requires. Then by providing physical input singals to the `chan_in` input of the `logic_analyzer` module, the logic analyzer is ready. Optionally some logic could be included in order to operate `trig_enable` via a toggling button instead of a switch (example in [`./src/boardspecific/readme.md`](../src/boardspecific/README.md)).

### Usage

After reset, the system automatically starts reading input signals and shows them on the vga display. Reading can be paused by pressing the "toggle `trig_enable` button". Furthermore switches allow to select which signals (channels) are visible, this also updates the header text and hides the associated channel number when invisible.

## Introduction

The goal of this project was to create a logic analyzer on an *Altera Max 10* FPGA, therefore development was done on a *Terasic DE10-Lite* FPGA board. Verilog was used as the hardware discription language. The output of the logic analyzer was chosen to be a VGA screen as seen in the screenshot above.

The project code is available in [this github repo](https://github.com/defermelowie/SOCOE-course-project/).

## Structure

The top level design file forwards all IO's to the `logic_analyzer` module. It also contains a PLL instance in order to create the correct clock frequency for the VGA display.

Within `logic_analyzer`, `sipo_shift_register` is instanciated `CHANNEL_COUNT` times. These registers contain the data from each channel. Next, in `pixel_to_channel`, a pixel is given as input and it is determined to which channel this pixel belongs (or which channel should be drawn using the given pixel). `data_to_pixelstatus` is then responsible for calculating the status of the pixel (on or off) using data from the corresponding channel. In order to draw the pixels on the VGA screen, `vga_timing_generator` does exactly what its name suggests: it generates timing signals such as `hsync` & `vsync` and keeps track of which pixel is currently drawn. Finnaly there are two RAM modules: `fontrom` which contains font data and `header_buffer`, the latter stores the info text of the header.

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

This module forms the cohesion of the other modules, it defines the structure and uses the other modules to generate the right vga signals. For example, in this module the `CHANNEL_COUNT` `sipo_shift_register` are generated. 

### Vga timing generator

[`vga_timing_generator`](../scr/vga_timing_generator) behaves as its name suggest. It generates timing signals for the VGA screen such as `hsync` and `vsync`. Furthermore the current pixel is kept track of as well as the next pixel. Finnaly it also provides info on wether or not the current pixel is visible, this is important since old CRT screens may brake when bombarded with electrons outside of the visible region.

```verilog
module vga_timing_generator (
    clk,                // input ---> clock signal (T_clock must match one pixel)
    reset,              // input ---> async reset signal
    display_col,        // output --> current column
    display_row,        // output --> current row
    display_next_col,   // output --> next column
    display_next_row,   // output --> next row
    visible,            // output --> is pixel at (current column, current row) visible?
    visible_next,       // output --> is pixel at (next column, next row) visible?
    hsync,              // output --> horizontal sync
    vsync               // output --> vertical sync
);
```

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

First it is determined what data (1 or 0) should be drawn at the current column, this could be done by selecting `data[pxl_col*sizeof(data)/h_res]` with `pxl_col` being the current pixel's column and `h_res` the total amount of columns (=horizontal resolution). However since divisions in hardware are extremely costly, the following workaround was used: 

1. Since `sizeof(data)/h_res` is a division between constants, it can be evaluated at synthesis time.
    * `sizeof(data)` is less than `h_res` and therefore integer division would give `0`. This is resolved by shifting `sizeof(data)` first.
1. At 'runtime' `pxl_col` is multiplied by the constant `sizeof(data)<<FP_SCALING_SHIFT/h_res`.
1. Finally the result is shifted back and the data for this column can be determined.

In code this looks the following:

```Verilog
// Constant function for fixed point division
localparam FP_SCALING_SHIFT = 12;

function integer fp_div;
    input integer dividend;
    input integer divisor;
    begin
        fp_div = (dividend<<FP_SCALING_SHIFT)/divisor;
    end  
endfunction

// Usage of the function
wire data_at_curr_pxl_col = data[(pxl_col*fp_div(DATA_SIZE,VGA_HOR_RES))>>FP_SCALING_SHIFT];
```

Now that the data at a given column is known the pixelstatus can be defined as shown below. With `pxl_data_high_status` and `pxl_data_low_status` being the status based on the current row for both cases.

```Verilog
assign pxl_status = ((data_at_curr_pxl_col) ? pxl_data_high_status : pxl_data_low_status)
```

Next, the only thing that remains is to draw vertical lines whenever the data value changes from the previous column to the current column. A change of data is simply defined as:

```verilog
wire data_change = data_at_curr_pxl_col != data_at_prev_pxl_col;
```

With `data_at_prev_pxl_col` defined in a similar way to `data_at_curr_pxl_col`.

Finally by changing the `pxl_status` assignment, vertical lines appear.

```verilog
assign pxl_status = ((data_at_curr_pxl_col) ? pxl_data_high_status : pxl_data_low_status) || (data_change && pxl_data_change_status);
```

### Pixel to channel

The [`pixel_to_channel`](../src/pixel_to_channel.v) module calculates the channel height, determines the channel number and whether or not a given pixel belongs to a channel. These outputs are derived from the current pixel row, the array with the channel enable signals and some parameters in the header files (more info below).

The definition of the IO's of this module looks the following:

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

In order to calculate the height of a channel, the total available height on the the monitor has to be divided by the total number of active channels. The total available height is the vertical resolution of the monitor subtracted by the offset for the header info. The number of active channels can be derived from the `channel_enable` input. 

Because a division in hardware requires a lot of logic elements and is slow we need to avoid using it. In this module fixed point operations are used to avoid the division. The idea is to multiply by a number smaller than 1 to become the same result as the desired division. For example, instead of dividing a number by 5, multiply it with 0,2. In order to do this for our purpose, to calculate `channel_height`, the total available height is multiplied by `multiply_factor`. This factor is an 11 bit precision factor between 0 and 1. The `multiply_factor` is composed as follows:

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

The multiply factors shown above represent the fractions `1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9` and `1/10`.  
If the result of the multiplication is shifted with 10 to the right, the (approx.) result of the desired division appears:

```Verilog
// Determine the height per channel
assign channel_height = ((VGA_VER_RES - OFFSET)*multiply_factor)>>10;
```

For inspiration, on how to solve problems with divisions, https://projectf.io/posts/fixed-point-numbers-in-verilog/ was used. More extensive information on fixed point division is available there.

### Sipo shift register

[This register](../src/sipo_shift_register.v) shifts one to the left when the `shift` input becomes `1`. Sipo is an acronym for "Serial In Parallel Out", this means that bits are read into the register in a serial fashion but the whole register is available as output.

![Sipo](./res/sipo.svg)

The size can be set using `SAMPLE_BUFF_SIZE` from `config.h` but a too large size results in timing issues

## Overview of used Intel® FPGA IP Cores

Their are three IP used in this project, two SDRAM blocks and one PLL.  
The PLL's is used for the appropriate clock signal. The frequency of the clock signal is depends on the resolution on the monitor. For example, if using a monitor with a resolution of 1280x1024 at 60Hz refresh rate a clock frequency of 108MHz is needed. The needed clock frequencies are mentioned in the [vga.h file](../src//vga.h).

The two SDRAM IP blocks are used for the header text, shown in the picture below:

![image](https://user-images.githubusercontent.com/61016433/122678836-b12bfd00-d1e8-11eb-8de9-e024ac9926b7.png)  

The `fontrom` block contains the pixel definition for 16x16 characters. These characters are addressed with their ascii number. The other SDRAM block is `header_buffer`, in this memory the ascii codes from the characters used in the header are saved. So the output of this block is used to feed the input of the fontrom block.

The image below shows an overview of the used logic of the FPGA:
![image](https://user-images.githubusercontent.com/61016433/122682805-dbd38100-d1fb-11eb-914f-b8112bb0eb08.png)

## Description of headers

### Config

[`config.h`](../src/config.h) contains general configuration parameters such as background colour, sample buffer size, ...

### VGA

[`vga.h`](../src/vga.h) defines the vga timing information.   

We included the timing parameters for the following resolutions:  
* 800x600 at 60Hz refresh rate  
* 1280x1024 at 60Hz refresh rate  
* 1440x900 at 60Hz refresh rate  
* 1920x1080 at 60Hz refresh rate  
