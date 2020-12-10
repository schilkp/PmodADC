# PmodADC

### Philipp Schilk, 2020

## Description
A fully discrete 14bit, 41kHz, Successive-Approximation Audio ADC and 14bit 41kHz R2R Audio DAC 
controlled by an [iCEBreaker FPGA board](https://1bitsquared.com/collections/fpga/products/icebreaker). 

![Overview](Doc/imgs/PmodADC.jpeg)

## Details

## Demos

These are a few demonstrations of the PmodADC and PmodDAC.

For each song, there are 3 files provided:  
    - The original (mono) wav file  
    - The song played back via a phone and recorded on the PmodADC  
    - The song played via the PmodDAC and recorded with a Focusrite Saffire Pro 40 Interface.  

Note that all audio files are provided at 44.1kHz to allow for easier playback:  
The PmodADC demos were played back at 44.1kHz and upsampled from 41kHz after recording.  
The PmodDAC demos were downsampled to 41kHz for playback, and recorded at 44.1kHz.   

All music by Kevin MacLeod, see Music Attribution below.

The wav files can be found [here](Doc/Demos), or via the Soundcloud links below:

| *Song* 	| *Original* 	| *PmodADC Demo* 	| *PmodDAC Demo* 	|
|:-:	|:-:	|:-:	|:-:	|
| New Hero in Town 	| [here](https://soundcloud.com/user-489490213/new-hero-in-town-reference) 	| [here](https://soundcloud.com/user-489490213/new-hero-in-town-pmodadc) 	| (Will follow soon) 	|
| Protofunk 	| [here](https://soundcloud.com/user-489490213/protofunk-reference) 	| [here](https://soundcloud.com/user-489490213/protofunk-pmodadc) 	| (Will follow soon) 	|
| Whiskey on the Mississippi 	| [here](https://soundcloud.com/user-489490213/whiskey-on-the-mississippi-reference) 	| [here](https://soundcloud.com/user-489490213/whiskey-on-the-mississippi-pmodadc) 	| (Will follow soon) 	|
| The Parting 	| [here](https://soundcloud.com/user-489490213/the-parting-reference) 	| [here](https://soundcloud.com/user-489490213/the-parting-pmodadc) 	| (Will follow soon) 	|

Alternatively, a single website with all the above audio files can be found [here](https://soundcloud.com/user-489490213/sets/pmodadc-demonstration).

[PmodDAC Demos will follow in a few days]

## Setup

A guide to setting up the open-source [apio](https://github.com/FPGAwars/apio) tool-chain can be found [here](Doc/ToolchainSetup.md).   

This project requires some hardware modifications to the iCEbreaker board. See [here](Doc/iCEBreakerMod.md) for details.  

The Python/Matlab scripts to play and record audio require some drivers and setup. See [here](Doc/FT2232H_Setup.md) for details.  

Two versions of the Verilog Code are provided:  
	- Setup 1, which immediately plays back the audio recorded by the PmodADC via the PmodDAC.  
	- Setup 2, which allows the PmodADC and PmodDAC to send/receive audio via USB.
	
See [here](iCEbreaker_HDL/Setup%20Description.md) for details.

## Python Utilities

The easiest way to record and play music is using the two python utilities provided [here](Scripts/Python/).

They rely on numpy, pyserial, wavio, and scipy:

```bash
> pip install -r requirements.txt
```

They have only been tested under python3.

### Record.py

Record music to a wav file using the PmodADC.

By default the audio is resampled to 44.1kHz.

Usage:

```
usage: Record.py [-h] (-s S | -n N | -i) [-r] comport outfile

positional arguments:
  comport     The COM port to which the board is connected.
  outfile     The filename under which the recorded audio should be saved.

optional arguments:
  -h, --help  show this help message and exit
  -s S        The number of seconds that should be recorded.
  -n N        The number of samples that should be recorded.
  -i          Recorded until a Keyboard Interrupt is received.
  -r          Do not re-sample audio to 44.1khz.
```

Record 10 seconds of audio from COM8 and save it to recording.wav:

```bash
python3 Record.py COM8 recording.wav -s 10
```

### Play.py

Play a wav file via the PmodDAC.

By default the wav file is resampled to 41kHz (if necessary). 

Usage:
```
usage: Play.py [-h] [-L | -R] [-r] comport wavfile

positional arguments:
  comport     The COM port to which the board is connected.
  wavfile     The filename of the audio file.

optional arguments:
  -h, --help  show this help message and exit
  -L          Play the left audio channel.
  -R          Play the right audio channel.
  -r          Do not re-sample audio to 41kHz.
```

Play the left channel of some_audio_file.wav via COM8:

```bash
python3 Play.py COM8 some_audio_file.wav -L
```

## Matlab Utilities

Matlab functions to communicate with the PmodADC/PmodDAC are also provided. 

See [Scripts/MATLAB/RecordAudioExample.m](Scripts/MATLAB/RecordAudioExample.m) and [Scripts/MATALB/PlayAudioExample.m](Scripts/MATALB/PlayAudioExample.m)

## Music Attribution

```
Protofunk by Kevin MacLeod  
Link: https://incompetech.filmmusic.io/song/4247-protofunk  
License: http://creativecommons.org/licenses/by/4.0/  

Whiskey on the Mississippi by Kevin MacLeod  
Link: https://incompetech.filmmusic.io/song/4624-whiskey-on-the-mississippi  
License: http://creativecommons.org/licenses/by/4.0/  
  
New Hero In Town by Kevin MacLeod  
Link: https://incompetech.filmmusic.io/song/5742-new-hero-in-town  
License: http://creativecommons.org/licenses/by/4.0/  

The Parting by Kevin MacLeod  
Link: https://incompetech.filmmusic.io/song/4501-the-parting  
License: http://creativecommons.org/licenses/by/4.0/  
```


