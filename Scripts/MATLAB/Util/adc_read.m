function [audio, fail_count] = adc_read(portname, nsamples)
%ADC_READ Read nsamples from the ADC connected to port portname
%   Returns the collection audio samples (uint16), and the number of 
%   packages that failed to decode. 
    sport = serialport(portname',9600, 'Timeout', 0.1);
    [audio, fail_count] = adc_read_openport(sport, nsamples);
    clear com;
end

