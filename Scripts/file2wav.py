from Utils.parse_recording import  parse_recording_data
from Utils.generate_wav import generate_wav

file_name = "filelog"

with open(file_name, 'rb') as binfile:
    raw_data = binfile.read()

# Process
audio, fail_count = parse_recording_data(raw_data)
print("Fails: " + str(fail_count))

# Write to file
generate_wav(audio, 'out1.wav')
