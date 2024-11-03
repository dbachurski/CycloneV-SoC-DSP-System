import unittest
import fpga
import time
import wave
import numpy as np
import threading

class TestStringMethods(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.fpga = fpga.FPGA()

    @classmethod
    def tearDownClass(cls):
        cls.fpga.close()

    # def tearDown(self):
    #     self.fpga.clear_memory()

    # def test_hps_write_ocm(self):
    #     with open('/usr/bin/dsp/data/data_to_send_32kB.txt', 'rb') as fd:
    #         data = fd.read()

    #     self.fpga.ocm1.write(data)

    #     read_buff = self.fpga.ocm1.read(len(data))

    #     self.assertEqual(read_buff.decode(), data.decode())

    # def test_dma_memory_write_memory(self):
    #     with open('/usr/bin/dsp/data/data_to_send_32kB.txt', 'rb') as fd:
    #         data = fd.read()
    #     transfer_length = len(data)

    #     self.fpga.ocm1.write(data)

    #     self.fpga.dma_mm_to_st.configure(transfer_length)
    #     self.fpga.dma_st_to_mm.configure(transfer_length)

    #     self.fpga.dma_st_to_mm.trigger()
    #     self.fpga.dma_mm_to_st.trigger()

    #     self.fpga.dma_st_to_mm.measure_bandwidth()

    #     read_buff = self.fpga.ocm2.read(len(data))

    #     self.assertEqual(read_buff.decode(), data.decode())

    # def test_csr_write(self):
    #     data_sizes = [1, 2, 4, 8]
    #     ranges = [(self.fpga.csr_addr, self.fpga.csr_addr + 0x8), (self.fpga.csr_addr + 0x100, self.fpga.csr_addr + 0x140)]

    #     for data_size in data_sizes:
    #         exp_data_dict = {}

    #         for start_addr, end_addr in ranges:
    #             for address in range(start_addr, end_addr, data_size):
    #                 data = bytes(random.getrandbits(8) for _ in range(data_size))
    #                 exp_data_dict[address] = data
    #                 self.fpga.write(address, data)

    #         for address, exp_data in exp_data_dict.items():
    #             read_data = self.fpga.read(address, len(exp_data))
    #             self.assertEqual(read_data, exp_data, f"transfer length: {len(exp_data)}, address: {hex(address)}")


    def dft_status_check(self, end_time):
        status = 0
        while status != 4:
            if time.time() > end_time:
                print("Error: timeout")
                break

            status_register = int.from_bytes(self.fpga.read(self.fpga.csr_addr + 0x008, 1), 'little')
            status = status_register & 0x7

            if status == 0:
                print("Status: DFT: IDLE")
            elif status == 1:
                print("Status: DFT: INPUT_STREAM")
            elif status == 2:
                print("Status: DFT: FULL_BUFFER")
            elif status == 3:
                print("Status: DFT: RUN_FFT")

    def memory_reader_status_check(self, end_time):
        status = 0
        while True:
            if time.time() > end_time:
                break

            status_register = int.from_bytes(self.fpga.read(self.fpga.csr_addr + 0x008, 1), 'little')
            status = status_register & 0x18

            if status == 0:
                print("Status: Memory Reader: IDLE")
            elif status == 1 or status == 2:
                print("Status: Memory Reader: RUNNING")

    def test_dft(self):
        transfer_length = 16 * 1024
        # transfer_length = 2 * 1024
        dft_enable_offset = 0x1
        dft_reset_offset = 0x2
        timeout = 1
        end_time = time.time() + timeout

        self.fpga.write(self.fpga.csr_addr + 0x004, (1 << dft_enable_offset).to_bytes(1, 'little'))

        with wave.open('/usr/bin/dsp/data/sine_wave_10Hz_100Hz.wav', 'rb') as wav_file:
            num_channels = wav_file.getnchannels()
            sample_width = wav_file.getsampwidth()
            num_frames = wav_file.getnframes()
            data = wav_file.readframes(num_frames)
            #data = wav_file.readframes(1024)

        if (((num_frames * num_channels * sample_width) * 2) < transfer_length):
            raise ValueError("Input signal length is too short")


        data = (np.frombuffer(data, dtype=np.int16)).astype(np.int32)
        data_bytes = data.tobytes()

        self.fpga.ocm1.write(data_bytes)

        dft_thread = threading.Thread(target=self.dft_status_check, args=(end_time,))
        dft_thread.start()

        self.fpga.dma_mm_to_st.configure(transfer_length)
        self.fpga.dma_st_to_mm.configure(transfer_length)

        self.fpga.dma_st_to_mm.trigger()
        self.fpga.dma_mm_to_st.trigger()

        print("DMA triggered")

        memory_reader_thread = threading.Thread(target=self.memory_reader_status_check, args=(end_time,))
        memory_reader_thread.start()

        # time.sleep(1)
        # self.fpga.write(self.fpga.csr_addr + 0x004, (1 << dft_reset_offset).to_bytes(1, 'little'))

        dft_thread.join()
        memory_reader_thread.join()

        self.assertEqual(self.fpga.read(self.fpga.csr_addr + 0x008, 1)[0] & 0x7, 4)
        self.assertEqual((self.fpga.read(self.fpga.csr_addr + 0x008, 1)[0] & 0x18) >> 3, 0)


unittest.main()
