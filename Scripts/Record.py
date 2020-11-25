import serial
from Utils.find_samples import find_samples
import wavio
import numpy as np
import matplotlib.pyplot as plt

port = "COM8"
record_time_seconds = 5
sample_rate = 41000

total_sample_count = 2 * sample_rate * record_time_seconds  # 2 bytes per sample
index = 0
Data = np.zeros(total_sample_count, dtype=int)
next_percent = 1

with serial.Serial(port) as comport:
    while index < total_sample_count:
        if comport.in_waiting > 0:
            data_read = comport.read(comport.in_waiting)
            for byte in data_read:
                Data[index] = byte
                index += 1
                if index == total_sample_count:
                    break
            if 100*index/total_sample_count > next_percent:
                print(str(next_percent) + "%")
                next_percent += 1

(samples, fail_count) = find_samples(Data)

print("Fails: " + str(fail_count))

audio = np.array(samples, dtype=float)

# Remove DC offset, determined experimentally
audio = audio - 8137
# print("mean: "+str(audio.mean()))

# Scale to -1 to 1
audio = audio / 8191

# write to wav file
wavio.write("out1.wav", audio, sample_rate, sampwidth=3)

# plt.plot(audio)
# plt.show()
