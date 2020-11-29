import serial
from serial import SerialException
import sys
import serial.tools.list_ports


# Make sure we got 1 argument.
if len(sys.argv) != 2:
    print('Did not receive expected number of Arguments.')
    print('Please specify COM port.')
    sys.exit()

# Make sure the argument we got is a COM port
port_name = sys.argv[1]
port_names = []
for port in serial.tools.list_ports.comports():
    port_names.append(port.device)

if port_name not in port_names:
    print('Did not find specified COM port!')
    sys.exit()

print('OK')

with serial.Serial(port_name, timeout=1) as comport:
    while True:
        try:
            comport.read(comport.in_waiting)
        except SerialException:
            print('Serial Exception!')
            pass
