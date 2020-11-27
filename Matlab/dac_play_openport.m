function dac_play_openport(sport, audio)
    packages = zeros(size(audio,2)*2,1);
    for index = 1:size(audio,2)
       [pckg1, pckg2] = generate_packages(audio(index));
       packages(index*2) = pckg1;
       packages(index*2+1) = pckg2;
    end
    write(sport, packages,"uint8");
end

