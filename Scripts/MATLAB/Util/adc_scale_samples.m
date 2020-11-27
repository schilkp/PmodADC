function audio = adc_scale_samples(samples)
%ADC_SCALE_SAMPLES Converts readings from the ADC to double audio values
%   Takes uint16 samples, and offsets and scales them to [-1,1] doubles.
    max_reading = 2^14-1;
    dc_offset = 8137; % Determined experimentally
    
    % Convert to double:
    audio = double(samples);
        
    % Remove DC offset:
    audio = audio - dc_offset;
    
    % Scale to [-1,1]:
    max_amplitude = max(dc_offset, max_reading-dc_offset);
    audio = audio/max_amplitude;
end
