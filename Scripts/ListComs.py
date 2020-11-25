import serial.tools.list_ports

port_list = serial.tools.list_ports.comports()
lg = len(port_list)
msg = ""
if lg == 0:
    msg = "No serial ports found...."
else:
    msg = str(lg) + " Serial port(s) found:"
    for p in port_list:
        msg += "\n" + p.device + ": " + p.description

print(msg.rstrip('\n'))