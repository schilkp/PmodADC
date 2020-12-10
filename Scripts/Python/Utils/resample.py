import scipy.signal as sps
import numpy as np


def resample_audio(audio, fs_from, fs_to):
    number_of_samples = round(len(audio) * float(fs_to) / fs_from)
    audio = sps.resample(audio, number_of_samples)

    # Ensure re-sampling did not create samples outside of [-1,1]:
    max_amplitude = np.abs(audio).max()

    if max_amplitude > 1:
        audio = audio / max_amplitude

    return audio
