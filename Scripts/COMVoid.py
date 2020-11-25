import serial
from serial import SerialException

port = "COM8"

with serial.Serial(port, timeout=1) as comport:
    while True:
        try:
            comport.read()
        except SerialException:
            print('Serial Exception!')
            pass
