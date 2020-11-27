function packages = generate_packages(audio)
%GENERATE_PACKAGES generate packages for the DAC from audio samples
%   audio must be scaled uint16 samples.
    packages = zeros(size(audio,1)*2,1);
    for index = 1:size(audio,1)
        value = bitand(uint16(audio(index)),uint16(0x3FFF));
        pckg1 = bitor(uint16(0x80),bitshift(uint16(value),-7));
        pckg2 = bitand(uint16(value),uint16(0x7F));
       packages(index*2) = pckg1;
       packages(index*2+1) = pckg2;
    end
end

