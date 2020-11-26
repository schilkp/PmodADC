function [audio, sample_count, fail_count] = adc_read(nsamples)
   com = serialport('COM8',9600, 'Timeout', 0.1);
   [audio, sample_count, fail_count] = adc_read_openport(nsamples,com);
   clear com;
end

