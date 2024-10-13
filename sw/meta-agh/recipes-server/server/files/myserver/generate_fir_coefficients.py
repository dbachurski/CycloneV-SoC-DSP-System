import numpy as np
import os

def generate_lowpass_coefficients(cutoff_freq, sampling_rate):
    num_taps = 32

    fc = cutoff_freq / (sampling_rate / 2)
    n = np.arange(num_taps)
    middle = (num_taps - 1) / 2

    h = np.sinc(2 * fc * (n - middle))

    window = np.hamming(num_taps)
    h = (h * window) / np.sum(h)

    h = np.int16(h * 16384)

    return h

def save_fir_coefficients(fir_coefficients):
    output_file_path = os.path.join('/usr/bin/dsp/data', 'low_pass.txt')

    try:
        with open(output_file_path, 'w') as fd:
            for coeff in fir_coefficients:
                fd.write(f"{coeff}\n")
        return True
    except Exception as e:
        return False