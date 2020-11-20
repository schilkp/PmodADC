import serial

port = "COM8"

with serial.Serial(port, timeout=1) as comport:
    while True:
        try:
            comport.read(1)
        except:
            print('?')
            pass
