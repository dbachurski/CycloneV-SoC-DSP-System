import os
import fpga
import wave
import time
import argparse
import numpy as np
import sys

MAX_BYTES = 32 * 1024

class Controller:
    def __init__(self):
        self.fpga = fpga.FPGA()
        self.control_register_offset = 0x4
        self.fir_enable_offset = 0x0
        self.tea_enable_offset = 0x1
        self.tea_mode_offset = 0x2
        self.fir_coefficients_offset = 0x100

    def read_wav_file(self, file_path, mode):
        try:
            if not os.path.exists(file_path):
                print(f"Error: File '{file_path}' does not exist.")
                sys.exit(1)

            with wave.open(file_path, 'rb') as wav_file:
                self.sampling_rate = wav_file.getframerate()
                self.num_channels = wav_file.getnchannels()
                self.sample_width = min(wav_file.getsampwidth(), 2)
                self.max_samples = MAX_BYTES // 2
                self.num_frames = min(wav_file.getnframes(), self.max_samples // self.num_channels)
                self.frames = wav_file.readframes(self.num_frames)

            if (mode == 'decrypt'):
                if (self.num_channels == 2):
                    data = np.frombuffer(self.frames, dtype=np.int16)
                    processed_signal_low = data[::2]
                    processed_signal_high = data[1::2]
                    self.data = (processed_signal_high.astype(np.int32) << 16) | (processed_signal_low.astype(np.int32) & 0xFFFF)
                else:
                    raise ValueError("Invalid WAV file: WAV file should have 2 channels for decryption")
            else:
                self.data = (np.frombuffer(self.frames, dtype=np.int16)).astype(np.int32)

            self.transfer_lenght = self.num_frames * self.sample_width * 2
            print(f"Transfer lenght: {self.transfer_lenght} Bytes.")
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
        raw_data = np.frombuffer(read_buff, dtype=np.int32)

        return raw_data

    def start_data_processing(self, processing_type):
        if (processing_type == 'fir'):
            self.fpga.write(self.fpga.csr_addr + self.control_register_offset,
                (1 << self.fir_enable_offset).to_bytes(1, 'little'))
        elif (processing_type == 'encrypt'):
            self.fpga.write(self.fpga.csr_addr + self.control_register_offset,
                (1 << self.tea_enable_offset).to_bytes(1, 'little'))
        elif (processing_type == 'decrypt'):
            self.fpga.write(self.fpga.csr_addr + self.control_register_offset,
                ((1 << self.tea_enable_offset) | (1 << self.tea_mode_offset)).to_bytes(1, 'little'))
        else:
            raise ValueError(f"Invalid processing type: {processing_type}."
                "Choose from 'fir', 'encrypt', or 'decrypt'.")

        self.fpga.dma_mm_to_st.configure(self.transfer_lenght)
        self.fpga.dma_st_to_mm.configure(self.transfer_lenght)

        self.fpga.dma_st_to_mm.trigger()
        self.fpga.dma_mm_to_st.trigger()

    def save_data(self, processed_signal, mode):
        output_dir = '/usr/bin/dsp/output'
        os.makedirs(output_dir, exist_ok=True)

        try:
            if mode == 'encrypt':
                processed_signal_low = (processed_signal & 0xFFFF).astype(np.int16)
                processed_signal_high = ((processed_signal >> 16) & 0xFFFF).astype(np.int16)
                processed_signal = np.stack((processed_signal_low, processed_signal_high), axis=1)
            else:
                processed_signal = (processed_signal & 0xFFFF).astype(np.int16)

            wav_file_path = os.path.join(output_dir, 'processed_signal.wav')
            with wave.open(wav_file_path, 'wb') as wav_file:
                if processed_signal.ndim == 2:
                    wav_file.setnchannels(2)
                else:
                    wav_file.setnchannels(1)
                wav_file.setsampwidth(self.sample_width)
                wav_file.setframerate(self.sampling_rate)
                wav_file.writeframes(processed_signal.tobytes())
            print(f"Output data saved in file '{wav_file_path}'.")

            txt_file_path = os.path.join(output_dir, 'processed_signal.txt')
            with open(txt_file_path, 'w') as txt_file:
                for sample in processed_signal:
                    txt_file.write(f"{sample}\n")
            print(f"Output data saved in file '{txt_file_path}'.")
        except Exception as e:
            print(f"Error saving filtered data: {e}")

    def clear_memory(self):
        self.fpga.clear_memory()

def main(signal_file_path, coefficients_file_path, mode):
    controller = Controller()

    if mode == 'fir':
        if controller.read_fir_coefficients(coefficients_file_path):
            controller.write_fir_coefficients()

    if controller.read_wav_file(signal_file_path, mode):
        controller.write_data()
        controller.start_data_processing(mode)

        time.sleep(0.3)
        filtered_data = controller.read_data()
        controller.save_data(filtered_data, mode)

    controller.clear_memory()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('signal_file_path', type=str)
    parser.add_argument('mode', choices=['fir', 'encrypt', 'decrypt'])
    parser.add_argument('coefficients_file_path', type=str, nargs='?', default=None)
    args = parser.parse_args()

    print(f"Selected processing mode: {args.mode}, coefficients file path: {args.coefficients_file_path}.")

    if args.mode == 'fir' and args.coefficients_file_path is None:
        print("Error: FIR coefficients file is required when mode is 'fir'.")
        sys.exit(1)

    main(args.signal_file_path, args.coefficients_file_path, args.mode)
