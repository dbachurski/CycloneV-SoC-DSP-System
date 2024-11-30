import numpy as np
import os

def generate_lowpass_coefficients(cutoff_freq, sampling_rate):
    num_taps = 32

    fc = cutoff_freq / (sampling_rate / 2)
    n = np.arange(num_taps)
    middle = (num_taps - 1) / 2

    h = np.sinc(fc * (n - middle))

    welch_window = 1 - ((n - middle) / (middle + 1))**2
    h = (h * welch_window) / np.sum(h)

    h = h / np.sum(h)

    h = np.int16(h * 16384)

    return h

def generate_highpass_coefficients(cutoff_freq, sampling_rate):
    num_taps = 32

    h_lowpass = generate_lowpass_coefficients(cutoff_freq, sampling_rate).astype(float) / 16384.0

    delta = np.zeros(num_taps)
    delta[num_taps // 2] = 1

    h = delta - h_lowpass

    h = np.int16(h * 16384)

    return h

def generate_bandpass_coefficients(low_cutoff, high_cutoff, sampling_rate):
    h_lowpass = generate_lowpass_coefficients(high_cutoff, sampling_rate).astype(float) / 16384.0
    h_highpass = generate_highpass_coefficients(low_cutoff, sampling_rate).astype(float) / 16384.0

    h = h_lowpass - h_highpass

    h = np.int16(h * 16384)

    return h

def save_fir_coefficients(fir_coefficients):
    output_file_path = os.path.join('/usr/bin/dsp/data', 'filter.txt')

    try:
        with open(output_file_path, 'w') as fd:
            for coeff in fir_coefficients:
                fd.write(f"{coeff}\n")
        return True
    except Exception as e:
        return False