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
