function dac_set(val)
    com = serialport('COM8',9600, 'Timeout', 0.1);
    %flush(com);
    [pckg1,pckg2] = generate_packages(val);
    write(com,pckg1,"uint8");
    write(com,pckg2,"uint8");
    clear com;
end