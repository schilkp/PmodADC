import serial
from Utils.generate_package import generate_package


def set_dac(port, value):
    with serial.Serial(port) as comport:
        comport.write(generate_package(value))
