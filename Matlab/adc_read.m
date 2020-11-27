function [audio, sample_count, fail_count] = adc_read(portname, nsamples)
   sport = serialport(portname',9600, 'Timeout', 0.1);
   [audio, sample_count, fail_count] = adc_read_openport(sport, nsamples);
   clear com;
end

