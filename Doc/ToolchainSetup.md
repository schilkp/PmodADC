# Toolchain Setup notes

A quick guide on how to setup the open-source [APIO](https://github.com/FPGAwars/apio) tool-chain for the [iCEbreaker](https://1bitsquared.com/collections/fpga/products/icebreaker) FPGA board under *Windows*.

## Installation and Build

###	Prerequisites

 - A working python3 environment.


### Toolchain install
First, install the apio toolchain:
```bash
> pip install -U apio
> apio install --all
```

### USB Drivers
With the board connected, the USB drivers can be installed. 
This will have to be redone if the board is connected to a 
different USB port. 

```bash
> apio drivers --ftdi-enable
```

In the pop-up, find the board ('iCEBreaker (Interface 0)') and
replace the driver with 'libusb' using the labeled button.

Once this is completed, reconnect the board.

### Build and upload
To verify the verilog code:
```bash
> apio verify
```

To build:
```bash
> apio build
```

To verify, build, upload:
```bash
> apio upload
```

### Analyze
To do a timing analysis:
```bash
> apio time
```

To get more information about the build (including FPGA usage):
```bash
> apio build -v
```

To start the simulation (requires a testbench):
```bash
> apio sim
```

## New Project Setup
To initiate a new project in an directory:
```bash
> apio init --board iCEBreaker
```
