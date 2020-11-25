from Utils.find_samples import find_samples
import wavio
import numpy as np
import matplotlib.pyplot as plt

file_name = "filelog"
count = 0
sample_rate = 41000

with open(file_name, 'rb') as binfile:
    Data = binfile.read()

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
