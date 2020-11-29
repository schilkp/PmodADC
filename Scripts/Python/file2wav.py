from Utils.Data_Parsing import parse_recording_data
from Utils.File_Interface import generate_wav
import sys

# Make sure we got 1 argument.
if len(sys.argv) != 3:
    print('Did not receive expected number of Arguments.')
    print('Please specify binary log file and output file name!')
    print('file2wav.py putty.log output.wav')
    sys.exit()

file_name = sys.argv[1]
out_name = sys.argv[2]

try:
    with open(file_name, 'rb') as bin_file:
        raw_data = bin_file.read()
except FileNotFoundError as e:
    print('File not found!')
    sys.exit()

# Process
audio, fail_count = parse_recording_data(raw_data)
print("Audio Decoded!")
print("Package decode fails: " + str(fail_count))

# Write to file
generate_wav(audio, out_name)
