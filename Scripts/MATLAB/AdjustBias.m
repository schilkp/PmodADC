% Script to help Adjust bias correctly. 

% Decide how many samples to record
record_n_samples = 20000;
port_name = 'COM6';

% Optimal Value:
optimal = int32(floor((2^14-1)/2));

% Record audio
while 1 
    [audio, fail_count] = adc_read(port_name, record_n_samples);
    sample_mean = mean(audio);
    disp([int2str(sample_mean),' Delta: ',int2str(int32(sample_mean)-optimal)])
end

