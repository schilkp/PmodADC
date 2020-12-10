function dac_play(portname, audio)
%DAC_PLAY play audio through port portname
%   Takes an array of (uint16) audio samples, and plays the through the DAC
%   connected to the port with name portname.
    sport = serialport(portname,9600);
    dac_play_openport(sport,audio);
    clear sport;
end

