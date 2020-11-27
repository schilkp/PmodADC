function dac_play_openport(sport, audio)
%DAC_PLAY play audio through serialdevice sport
%   Takes an array of (uint16) audio samples, and plays the through the DAC
%   connected to the serialdevice sport.
%   
%   Otherwise functionally identical to dac_play, but can be used to 
%   avoid re-opening the serialdevice every time for 
%   successive calls.
    packages = generate_packages(audio);
    write(sport, packages, "uint8");
end

