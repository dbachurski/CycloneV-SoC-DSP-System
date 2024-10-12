import os
import fpga
import wave
import time
import argparse
import numpy as np
import sys

class Controller:
    def __init__(self):
        self.fpga = fpga.FPGA()
        self.fir_enable_offset = 0x004
        self.fir_coefficients_offset = 0x100

    def read_wav_file(self, file_path):
        try:
            if not os.path.exists(file_path):
                print(f"Error: File '{file_path}' does not exist.")
                sys.exit(1)

            with wave.open(file_path, 'rb') as wav_file:
                self.sampling_rate = wav_file.getframerate()
                self.num_channels = wav_file.getnchannels()
                self.sample_width = wav_file.getsampwidth()
                self.num_frames = wav_file.getnframes()
                self.data = wav_file.readframes(self.num_frames)

            self.transfer_lenght = self.num_frames * self.num_channels * self.sample_width
            self.data = np.frombuffer(self.data, dtype=np.int16)
            self.data_bytes = self.data.tobytes()
            print(f"Successfully read WAV file '{file_path}'.")
            return True
        except Exception as e:
            print(f"Error reading WAV file '{file_path}': {e}")
            sys.exit(1)

    def read_wav_file(self, file_path):
        try:
            if not os.path.exists(file_path):
                print(f"Error: File '{file_path}' does not exist.")
                sys.exit(1)

            with wave.open(file_path, 'rb') as wav_file:
                self.sampling_rate = wav_file.getframerate()
                self.num_channels = wav_file.getnchannels()
                self.sample_width = wav_file.getsampwidth()
                self.num_frames = wav_file.getnframes()
                self.data = wav_file.readframes(self.num_frames)

            self.transfer_lenght = self.num_frames * self.num_channels * self.sample_width
            self.data = np.frombuffer(self.data, dtype=np.int16)
            self.data_bytes = self.data.tobytes()
            print(f"Successfully read WAV file '{file_path}'.")
            return True
        except Exception as e:
            print(f"Error reading WAV file '{file_path}': {e}")
            sys.exit(1)

    def read_fir_coefficients(self, file_path):
        try:
            if not os.path.exists(file_path):
                print(f"Error: File '{file_path}' does not exist.")
                sys.exit(1)

            with open(file_path, 'r') as fd:
                coefficients = np.array([int(line.strip()) for line in fd], dtype=np.int16)
                self.coefficients = coefficients.tobytes()
            print(f"Successfully read FIR coefficients from '{file_path}'.")
            return True
        except Exception as e:
            print(f"Error reading FIR coefficients from '{file_path}': {e}")
            sys.exit(1)

    def write_fir_coefficients(self):
        print(self.coefficients)
        self.fpga.write(self.fpga.csr_addr + self.fir_coefficients_offset, self.coefficients)

    def write_data(self):
        self.fpga.ocm1.write(self.data_bytes)

    def read_data(self):
        read_buff = self.fpga.ocm2.read(len(self.data_bytes))
        filtered_signal = np.frombuffer(read_buff, dtype=np.int16)
        return filtered_signal

    def start_data_processing(self):
        self.fpga.write(self.fpga.csr_addr + self.fir_enable_offset, (1).to_bytes(4, byteorder='little'))

        self.fpga.dma_mm_to_st.configure(self.transfer_lenght)
        self.fpga.dma_st_to_mm.configure(self.transfer_lenght)

        self.fpga.dma_st_to_mm.trigger()
        self.fpga.dma_mm_to_st.trigger()

    def save_data(self, filtered_signal):
        output_dir = '/usr/bin/dsp/output'
        os.makedirs(output_dir, exist_ok=True)

        try:
            wav_file_path = os.path.join(output_dir, 'filtered_signal.wav')
            with wave.open(wav_file_path, 'wb') as wav_file:
                wav_file.setnchannels(self.num_channels)
                wav_file.setsampwidth(self.sample_width)
                wav_file.setframerate(self.sampling_rate)
                wav_file.writeframes(filtered_signal.tobytes())
            print(f"Output data saved in file '{wav_file_path}'.")

            txt_file_path = os.path.join(output_dir, 'filtered_signal.txt')
            with open(txt_file_path, 'w') as txt_file:
                for sample in filtered_signal:
                    txt_file.write(f"{sample}\n")
            print(f"Output data saved in file '{txt_file_path}'.")
        except Exception as e:
            print(f"Error saving filtered data: {e}")

    def clear_memory(self):
        self.fpga.clear_memory()

def main(signal_file_path, coefficients_file_path):
    controller = Controller()

    if controller.read_fir_coefficients(coefficients_file_path):
        controller.write_fir_coefficients()

    if controller.read_wav_file(signal_file_path):
        controller.write_data()
        controller.start_data_processing()

        time.sleep(0.3)
        filtered_data = controller.read_data()
        controller.save_data(filtered_data)

    controller.clear_memory()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('signal_file_path', type=str)
    parser.add_argument('coefficients_file_path', type=str)
    args = parser.parse_args()

    main(args.signal_file_path, args.coefficients_file_path)
