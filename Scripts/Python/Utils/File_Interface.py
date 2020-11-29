import wavio


def generate_wav(audio, file_name, sample_rate=41000):
    """
    Generate .wav file from recorded audio
    :param audio: Numpy array of audio samples
    :param file_name: File name
    :param sample_rate: Audio sample rate. (Default = 41000)
    :return: None
    """
    wavio.write(file_name, audio, sample_rate, sampwidth=3)


max_value_for_sampwidth = [255, 32767, 8388607, 2147483647]
min_value_for_sampwidth = [0, -32768, -8388608, -2147483648]


def read_wav(file_name, channel=0):
    wav = wavio.read(file_name)

    # Make sure the specified channel exists:
    if wav.data.shape[1] < channel:
        raise ValueError('Specified Channel does not exist!')

    # Pick the channel, convert to float
    audio = wav.data[:, channel].astype('double')

    # Determine maximum value, depending sample width:
    max_value = max_value_for_sampwidth[wav.sampwidth-1]
    min_value = min_value_for_sampwidth[wav.sampwidth-1]

    # Scale to [-1,1]:
    audio = (audio - min_value) * 2 / (max_value-min_value) - 1

    return audio
