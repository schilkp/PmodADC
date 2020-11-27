function dac_set(portname, val)
    sport = serialport(portname,9600, 'Timeout', 0.1);
    dac_set_openport(sport,val);
    clear com;
end