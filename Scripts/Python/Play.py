import argparse
from Utils.File_Interface import read_wav
from Utils.Data_Parsing import convert_float_to_uint_audio
from Utils.Data_Parsing import generate_packages
from Utils.Interface import play_data
from Utils.Interface import play_data_async_packaging

# Setup argument parser
parser = argparse.ArgumentParser(prog='Play.py', description='Play Audio through the PmodDAC.\n'
                                                             'Note that the sample rate is discarded and the audio is'
                                                             'played at 41kHz.')
parser.add_argument('comport', help='The COM port to which the board is connected.')
parser.add_argument('wavfile', help='The filename of the audio file.')
length_group = parser.add_mutually_exclusive_group(required=False)
length_group.add_argument('-L', action='store_true', help='Play the left audio channel.')
length_group.add_argument('-R', action='store_true', help='Play the right audio channel.')

# Parse arguments:
args = parser.parse_args()

# Load the audio data:
if args.L or (not args.L and not args.R):
    audio = read_wav(args.wavfile, channel=0)
else:
    audio = read_wav(args.wavfile, channel=1)

# Scale the audio data:
audio = convert_float_to_uint_audio(audio)

# Play the audio:
play_data_async_packaging('COM8', audio)
