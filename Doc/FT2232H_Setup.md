# Driver Install

Install the [FTDI VCP driver](https://www.ftdichip.com/Drivers/VCP.htm).

Select the 'setup executable' from the 'Comments' column. 

# FT_Prog Install

Install the [FT_PROG Utility](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG).

# FT2232H Config

 - Open the FT_PROG Utility.
 - Press *F5* to scan for devices
 - Find the iCEBreaker's FTDI Chip
	- Identifiable by property 'Product Desc'='iCEBreaker V1.0e'
 - Set Port B to FIFO
	- Device -> FT EEPROM -> Hardware Specific -> *Port B* -> Hardware, select '245 FIFO'
 - Press *Ctrl-P* to program the FT2232H

# Driver Config
 - Find the Virtual COM port in Windows' Device Manager, right click, select 'Properties'
 - Under the 'Port Settings' tab, select 'Advanced' 
 - Set both the Transmit and Receive buffer size to '256', and the latency timer to '2ms'
 - Click OK

# Re-install libUSB for iCEBreaker
For apio to be able to program the Device after this step,
you will have to re-replace the driver with libUSB:

```bash
> apio drivers --ftdi-enable
```

