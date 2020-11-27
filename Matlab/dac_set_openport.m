function dac_set_openport(sport,val)
    flush(sport);
    [pckg1,pckg2] = generate_packages(val);
    write(sport,[pckg1,pckg2],"uint8");
end

