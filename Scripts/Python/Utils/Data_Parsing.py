import numpy as np


def generate_packages(audio):
    n_samples = audio.shape[0]

    # result = np.zeros(n_samples*2, dtype='uint8')
    result = bytearray(n_samples*2)

    for i in range(n_samples):
        sample = audio[i]
        pckg1 = ((sample >> 7) & 0x7F) | 0x80
        result[i*2] = pckg1
        pckg2 = sample & 0x7F
        result[i*2+1] = pckg2

    return result


def convert_wav_audio(audio):
    """
    Converts a numpy array of double [-1,1] audio samples to properly scaled, 14-bit audio samples
    :param audio: numpy array of double [-1,1] audio samples
    :return: uint16 numpy array of scaled 14-bit audio samples
    """

    if audio.max() > 1 or audio.min() < -1:
        raise ValueError('Audio out of bounds!')

    max_reading = 0x3FFF

    audio = audio + 1
    audio = audio / 2
    audio = audio * max_reading
    audio = audio.astype('uint16')

    return audio


def parse_recording_data(data):
    """
    Parse a list of raw packages into a numpy array of audio samples, scaled to ADC full-scale
    :param data: List of samples (int)
    :return: (audio, fail_count)
            audio: numpy array of scaled audio samples
            fail_count: number of samples that could not be decoded
    """
    (samples, fail_count) = find_samples(data)

    audio = np.array(samples, dtype=float)

    max_reading = 0x3FFF

    # Theoretical offset is 8192, 8137 was determined experimentally
    dc_offset = 8137

    # Remove DC offset:
    audio = audio - dc_offset

    # Scale to -1,1
    # Because offset may not be perfectly centered, take max(max_reading-offset, offset) as the maximum
    # amplitude
    max_amplitude = max(max_reading - dc_offset, dc_offset)

    audio = audio / max_amplitude

    return audio, fail_count


def find_samples(data):
    """
    Parse a list of raw packages into a list of raw samples
    :param data: List of raw packages (int)
    :return: samples, fail_count.
             samples: List of raw samples
             fail_count: number of samples that could not be decoded
    """

    sample = None
    looking_for_pckg = 1
    samples = []
    fail_count = 0

    for i in range(len(data)):
        if looking_for_pckg == 1:
            # Check if this is a starting byte
            if (data[i] & 0x80) != 0:
                sample = (data[i] & 0x7F) << 7
                looking_for_pckg = 2
            else:
                fail_count = fail_count + 1
                continue
        else:
            # Check this is not a starting byte
            if (data[i] & 0x80) == 0:
                sample = (data[i] & 0x7F) | sample
                samples.append(sample)
                sample = None
                looking_for_pckg = 1
            else:
                sample = None
                looking_for_pckg = 1
                fail_count = fail_count + 1
                continue

    return samples, fail_count
