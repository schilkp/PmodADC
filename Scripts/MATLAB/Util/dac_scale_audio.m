function samples = dac_scale_audio(audio)
%DAC_SCALE_AUDIO Converts float audio to samples for the DAC
%   Takes [-1,1] doubles, converts them to properly scaled
%   uint16 samples ready for the DAC.
    max_reading = 2^14-1;

    if(max(audio) > 1 || min(audio) < -1)
        error('Audio Exceeds [-1,1] bounds!')
    end
    
    audio = audio + 1; % Offset to [0,2]
    audio = audio / 2; % Scale to [0,1]
    audio = audio * (max_reading); % Scale to [0,max_reading]
    samples = uint16(audio); % Convert to uint16  
end

