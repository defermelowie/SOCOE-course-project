# Logic Analyzer

*Butaye Jonathan & Deferme Lowie*

<img src="./res/screenshot.jpg" alt="Screenshot" style="zoom:15%;" />

## Structure

TODO: Show overview

### Top level design file

This file sits in `./src/boardspecific🗁` and therefore isn't present in the repo, however the folder contains a [readme](../src/boardspecific/README.md) with an example of this file.

The top lever design file contains a phase locked loop in order to provide the correct clock for the VGA display. Furthermore necessary IO's are forwarded to the `logic_analyzer` module here. 

### Logic analyzer

TODO

### Vga timing generator

TODO

### Data to pixelstatus

TODO

### Pixel to channel

TODO

### Sipo shift register

[This register](../src/sipo_shift_register.v) shifts one to the left when the `shift` input becomes `1`. Sipo is an acronym for "Serial In Parallel Out", this means that bits are read into the register in a serial fashion but the whole register is available as output.

![Sipo](./res/sipo.svg)
