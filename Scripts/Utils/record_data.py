import serial


def record_data(port, nsamples=-1, time_s=-1, sample_rate=41000, print_progress=True):
    """
    Record raw samples from the ADC
    :param port: The COM port to be read from
    :param nsamples: The number of samples to be recorded (Specify either nsamples or time_s)
    :param time_s: The time in seconds to be recorded (Specify either nsamples or time_s)
    :param sample_rate: Audio sample rate. (default = 41000)
    :param print_progress: Do print percent update. (default = True)
    :return: A list of raw samples
    """
    if nsamples != -1 and time_s != -1:
        raise ValueError("Cannot specify both nsamples and time_s!")
    elif nsamples != -1:
        total_sample_count = nsamples
    elif time_s != -1:
        total_sample_count = 2 * sample_rate * time_s  # 2 bytes per sample
    else:
        total_sample_count = -1
        print_progress = False  # Do not print progress if indefinite read
        raise NotImplementedError("Indefinite Recording not yet implemented! (Specify either nsamples or time_s)")

    index = 0
    data = []
    next_percent = 1

    with serial.Serial(port) as comport:
        while total_sample_count == -1 or index < total_sample_count:
            # Check if there is data to be read
            if comport.in_waiting > 0:

                # Read data and split into bytes
                data_read = comport.read(comport.in_waiting)
                for byte in data_read:
                    data.append(byte)
                    index += 1
                    if index == total_sample_count:
                        break

                # Print current progress
                if print_progress:
                    if 100 * index / total_sample_count > next_percent:
                        print(str(next_percent) + "%")
                        next_percent += 1

    return data
