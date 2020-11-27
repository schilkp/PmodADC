function [pckg1,pckg2] = generate_packages(value)
    value = bitand(uint16(value),uint16(0x3FFF));
    pckg1 = bitor(uint16(0x80),bitshift(uint16(value),-7));
    pckg2 = bitand(uint16(value),uint16(0x7F));
end

