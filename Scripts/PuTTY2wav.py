import numpy as np
import matplotlib.pyplot as plt
import sounddevice as sd
import time

# Read in log file
data = None
with open('heyjude', 'rb') as file:
    data = bytearray(file.read())

Samples = []

# filter out packages
Sample = None
looking_for_pckg = 1

fail_count = 0

for i in range(data.__len__()):
    if looking_for_pckg == 1:
        # Check if this is a starting byte
        if (data[i] & 0x80) != 0:
            Sample = (data[i] & 0x7F) << 7
            looking_for_pckg = 2
        else:
            # print("Expected Pckg1, skipping...")
            fail_count = fail_count + 1
            continue
    else:
        # Check this is not a starting byte
        if (data[i] & 0x80) == 0:
            Sample = (data[i] & 0x7F) | Sample
            Samples.append(Sample)
            Sample = None
            looking_for_pckg = 1
        else:
            Sample = None
            looking_for_pckg = 1
            # print("Expected Pckg2, skipping...")
            fail_count = fail_count + 1
            continue

print("Samples: " + str(data.__len__()))
print("Total Fail Count: " + str(fail_count))
print("Fails per found Samples: " + str(fail_count / float(data.__len__())))


ar = np.array(Samples) * 100000

plt.plot(ar)
plt.show()
sd.play(ar, 41000)
time.sleep(20)
sd.stop()
