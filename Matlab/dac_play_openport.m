function dac_play_openport(sport, audio)
    packages = generate_packages(audio);
    write(sport, packages,"uint8");
end

