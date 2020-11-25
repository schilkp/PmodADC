import numpy as np


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

    # Remove DC offset, determined experimentally
    audio = audio - 8137

    # Scale to -1 to 1
    audio = audio / 8191

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
