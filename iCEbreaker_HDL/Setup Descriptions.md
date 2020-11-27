# Setup 1: Mirror
Immediately play back PmodADC capture on PmodDAC.

Connections:
PMOD1A - PmodADC
PMOD1B - PmodDAC

# Setup 4: Audio Interface
Via USB: Transmit audio recorded by PmodADC, and receive audio for PmodDAC. 

Connections:
PMOD1A - PmodADC
PMOD1B - PmodDAC

Note:
Requires FT2232H to be reprogrammed to FIFO mode on Port B. (See Documentation [here](../Doc/FT2232H_Setup.md))
Requires iCEBreaker board to be slight modified. (See Documentation [here](../Doc/iCEBreakerMod.md))
See [here](../Scripts) for all computer-side scripts.
