from Utils.Interface import record_data
from Utils.Data_Parsing import parse_recording_data
from Utils.File_Interface import generate_wav
from Utils.resample import resample_audio
import argparse
from serial import SerialException
import sys


# Setup argument parser
parser = argparse.ArgumentParser(prog='Record.py', description='Record audio from the PmodADC to a wav file. '
                                                               'By default the audio is resampled to 44.1kHz '
                                                               'before saving.')
parser.add_argument('comport', help='The COM port to which the board is connected.')
parser.add_argument('outfile', help='The filename under which the recorded audio should be saved.')
length_group = parser.add_mutually_exclusive_group(required=True)
length_group.add_argument('-s', type=int, help='The number of seconds that should be recorded.')
length_group.add_argument('-n', type=int, help='The number of samples that should be recorded.')
length_group.add_argument('-i', action='store_true', help='Recorded until a Keyboard Interrupt is received.')
parser.add_argument('-r', action='store_true', help='Do not re-sample audio to 44.1 khz.')

# Parse arguments:
args = parser.parse_args()


# Record
try:
    if args.i:
        print('Recording until Keyboard interrupt.')
        raw_data = record_data(args.comport)
    elif args.n:
        print('Recording '+str(args.n)+' samples.')
        raw_data = record_data(args.comport, nsamples=args.n)
    elif args.s:
        print('Recording ' + str(args.s) + ' seconds.')
        raw_data = record_data(args.comport, time_s=args.s)
    else:
        raise Exception('Why was there no length argument? argparse....')
except SerialException as e:
    print('Serial Error!')
    print(e)
    sys.exit()

# Process
audio, fail_count = parse_recording_data(raw_data)
print("Package decode fails: " + str(fail_count))


f_s = 41000
# Re-sample, unless disabled:
if not args.n:
    f_s = 44100
    print('Re-sampling audio to 441000kHz...')
    audio = resample_audio(audio, 41000, 44100)

# Write to file
generate_wav(audio, args.outfile, sample_rate=f_s)

