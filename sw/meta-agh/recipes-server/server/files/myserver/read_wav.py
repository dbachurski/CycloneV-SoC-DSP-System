import wave
import numpy as np
import matplotlib.pyplot as plt
import argparse
import os

def save_wav_data_as_plot(file_path):
    with wave.open(file_path, 'rb') as wav_file:
        sampling_rate = wav_file.getframerate()
        num_channels = wav_file.getnchannels()
        num_frames = wav_file.getnframes()
        data = wav_file.readframes(num_frames)
        signal = np.frombuffer(data, dtype=np.int16)

        if num_channels > 1:
            signal = signal[::num_channels]

        signal = signal.astype(np.float32) / 16384
        time = np.arange(len(signal)) / sampling_rate
    base_name = os.path.splitext(file_path)[0]
    svg_file = f'{base_name}.svg'

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

    plt.savefig(svg_file, format='svg')
    plt.close()
    print(f'Sampling Rate: {sampling_rate} Hz')
    print(f'Plot saved as: {svg_file}')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path', type=str)
    args = parser.parse_args()

    save_wav_data_as_plot(args.file_path)