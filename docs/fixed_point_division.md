# Fixed point division

Since division is extremely costly it has to be avoided at all times. A solution may be to divide constants beforehand and use fixed point multiplication later. For example if the desired result is: `a*B/C` and `B`, `C` are constants one could calculate `B/C` beforehand and multiply this with `a` later.

```verilog
pxl_col*DATA_SIZE/VGA_HOR_RES = pxl_col*fp_div(DATA_SIZE, VGA_HOR_RES)>>FP_SCALING_SHIFT;

DATA_SIZE < VGA_HOR_RES => DATA_SIZE/VGA_HOR_RES = 0 // Integer division
DATA_SIZE << FP_SCALING_SHIFT > VGA_HOR_RES => (DATA_SIZE << FP_SCALING_SHIFT)/VGA_HOR_RES > 0
pxl_col*[(DATA_SIZE << FP_SCALING_SHIFT)/VGA_HOR_RES] >> FP_SCALING_SHIFT = pxl_col*DATA_SIZE/VGA_HOR_RES

a*B/C = ?
(B << SS) / C = T0  // Evaluate at 'compile time'
a*T0 = t1           // Evaluate at 'run time'
t1 >> SS = a*B/C    // Evaluate at 'run time'

T0 = fp_div(B, C)
a*T0 = t1       
t1 >> SS = a*B/C
```

```verilog
channel_height = (VGA_VER_RES - OFFSET)/channel_count;
visible_channel_number = (pixel_row - OFFSET) / ((VGA_VER_RES - OFFSET)/channel_count);
visible_channel_number = (pixel_row - OFFSET) * channel_count * (1 << SCALING / (VGA_VER_RES - OFFSET)) >> SCALING;
```