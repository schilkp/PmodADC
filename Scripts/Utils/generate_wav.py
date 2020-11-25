import wavio


def generate_wav(audio, file_name, sample_rate=41000):
    wavio.write(file_name, audio, sample_rate, sampwidth=3)
