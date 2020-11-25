from Utils.parse_recording import parse_recording_data
from Utils.record_data import record_data
from Utils.generate_wav import generate_wav

port = "COM8"
record_time_seconds = 5

# Record
raw_data = record_data(port, time_s=record_time_seconds)

# Process
audio, fail_count = parse_recording_data(raw_data)
print("Fails: " + str(fail_count))

# Write to file
generate_wav(audio, 'out1.wav')

