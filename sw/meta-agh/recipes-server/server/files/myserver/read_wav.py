import os
import wave
import numpy as np
import matplotlib.pyplot as plt
import argparse
import threading

MAX_BYTES = 32 * 1024

wav_signal = None
svg_file_name = None
sampling_rate = None

def save_wav_data_as_plot(file_path):
    global wav_signal, sampling_rate, svg_file_name
    with wave.open(file_path, 'rb') as wav_file:
        sampling_rate = wav_file.getframerate()
        num_channels = wav_file.getnchannels()

        max_samples = MAX_BYTES // 2
        num_frames = min(wav_file.getnframes(), max_samples)

        data = wav_file.readframes(num_frames)
        wav_signal = np.frombuffer(data, dtype=np.int16)

        if num_channels > 1:
            wav_signal = wav_signal[::num_channels]

        signal = wav_signal.astype(np.float32) / 16384
        time = np.arange(len(signal)) / sampling_rate

    if len(time) > sampling_rate:
        time = time[:sampling_rate]
        signal = signal[:sampling_rate]

    base_name = os.path.splitext(file_path)[0]
    svg_file_name = f'{base_name}.svg'

    plt.figure(figsize=(15, 8))
    plt.plot(time, signal, linewidth=2, alpha =0.8)
    plt.xlabel('Time [s]', fontsize=30, fontfamily='sans-serif', labelpad=17)
    plt.ylabel('Amplitude', fontsize=30, fontfamily='sans-serif')

    ax = plt.gca()
    ax.set_facecolor('#f0f0f0')
    plt.gcf().patch.set_facecolor('#fcfcfc')
    for spine in ax.spines.values():
        spine.set_linewidth(1.3)
    ax.spines['left'].set_position(('data', -0.02))
    plt.grid(True, color='gray', linestyle=':', linewidth=0.4)
    plt.xlim(-0.02, 1.02)
    plt.ylim(-2, 2)
    plt.xticks([0, 0.2, 0.4, 0.6, 0.8, 1], fontsize=22)
    plt.yticks(fontsize=22)

    plt.savefig(svg_file_name, format='svg')
    plt.close()

    print(f'Sampling Rate: {sampling_rate} Hz')
    print(f'Plot saved as: {svg_file_name}')

    thread = threading.Thread(target=plot_signal_dft)
    thread.start()

    return sampling_rate

def plot_signal_dft():
    global wav_signal, sampling_rate, svg_file_name
    wav_signal = wav_signal.astype(np.float32) / 16384

    svg_file_name = svg_file_name.replace('.svg', '_dft.svg')

    signal_dft = np.abs(np.fft.fft(wav_signal)) / len(wav_signal)
    freqs = np.fft.fftfreq(len(signal_dft), 1/sampling_rate)

    half_len = len(freqs) // 2
    signal_dft = signal_dft[:half_len] * 2
    freqs = freqs[:half_len]

    plt.figure(figsize=(15, 8))
    plt.plot(freqs, signal_dft, linewidth=2, alpha=0.8)
    plt.xlabel('Frequency [Hz]', fontsize=30, fontfamily='sans-serif', labelpad=17)
    plt.ylabel('Amplitude', fontsize=30, fontfamily='sans-serif')
    ax2 = plt.gca()
    ax2.set_facecolor('#f0f0f0')
    plt.gcf().patch.set_facecolor('#fcfcfc')
    for spine in ax2.spines.values():
        spine.set_linewidth(1.3)
    ax2.spines['left'].set_position(('data', -0.02))
    plt.grid(True, color='gray', linestyle=':', linewidth=0.4)
    xmax = min(200, sampling_rate / 2)
    plt.xlim(0, xmax)
    ticks = np.arange(0, xmax + 1, 20)
    plt.xticks(ticks, fontsize=22)
    plt.yticks(fontsize=22)

    plt.savefig(svg_file_name, format='svg')
    plt.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path', type=str)
    args = parser.parse_args()

    save_wav_data_as_plot(args.file_path)
