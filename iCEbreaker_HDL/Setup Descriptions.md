# Setup 1: Mirror
Immediately play back PmodADC capture on PmodDAC.

Connections:
PMOD1A - PmodADC
PMOD1B - PmodDAC

# Setup 2: ADC to I2S DAC
(TODO)

Immediately play back PmodADC capture on PmodI2S2 DAC.

Connections:
PMOD1A - PmodADC
PMOD1B - PmodI2S2

# Setup 3: I2S ADC to DAC
(TODO)

Immediately play back PmodI2S2 ADC capture on PmodDAC.

Connections:
PMOD1A - PmodI2S2
PMOD1B - PmodDAC

# Setup 4: Audio Interface
(TODO)

Via USB: Transmit audio recorded by PmodADC, and receive audio for PmodDAC. 

Connections:
PMOD1A - PmodADC
PMOD1B - PmodDAC

Note:
Requires FT2232H to be reprogrammed to FIFO mode on Port B. (See Documentation [here](Doc/FT2232H_Setup.md))
May require iCEBreaker board to be slight modified. (See Documentation [here](Doc/iCEBreakerMod.md))

