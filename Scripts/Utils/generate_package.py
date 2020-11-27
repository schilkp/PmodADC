def generate_package(value):
    pckg1 = ((value >> 7) & 0x7F) | 0x80
    pckg2 = value & 0x7F
    pckgs = (pckg1 << 8 | pckg2)
    return int.to_bytes(pckgs, 2, byteorder='big')
