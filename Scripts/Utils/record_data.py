import serial

def record_data(port, nsamples=-1, time_s=-1, sample_rate=44100, print_progress=True):
    total_sample_count = -1

    if nsamples != -1 and time_s != -1:
        raise ValueError("Cannot specify both nsamples and time_s!")
    elif nsamples != -1:
        total_sample_count = nsamples
    elif time_s != -1:
        total_sample_count = 2 * sample_rate * time_s  # 2 bytes per sample
    else:
        print_progress = False  # Do not print progress if infinite read

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
