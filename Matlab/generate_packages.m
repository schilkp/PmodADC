function packages = generate_packages(audio)
    packages = zeros(size(audio,2)*2,1);
    for index = 1:size(audio,2)
        value = bitand(uint16(audio(index)),uint16(0x3FFF));
        pckg1 = bitor(uint16(0x80),bitshift(uint16(value),-7));
        pckg2 = bitand(uint16(value),uint16(0x7F));
       packages(index*2) = pckg1;
       packages(index*2+1) = pckg2;
    end
end

