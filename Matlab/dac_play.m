function dac_play(portname, audio)
    sport = serialport(portname,9600);
    dac_play_openport(sport,audio);
    clear com;
end

