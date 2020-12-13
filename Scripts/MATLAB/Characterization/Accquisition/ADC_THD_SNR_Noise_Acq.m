n_samples = 41000*10;
port = 'COM6';
fs = 41000;

data = adc_read(port, n_samples);

if max(data) >= 2^14-1 || min(data) == 0
    disp('Warning! May have clipped!');
end