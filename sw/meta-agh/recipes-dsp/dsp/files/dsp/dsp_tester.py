import unittest
import fpga
import wave
import numpy as np
import random

class TestStringMethods(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.fpga = fpga.FPGA()

    @classmethod
    def tearDownClass(cls):
        cls.fpga.close()

    def tearDown(self):
        self.fpga.clear_memory()
        self.fpga.dma_st_to_mm.clear_control_register()
        self.fpga.dma_mm_to_st.clear_control_register()

    def configure_and_trigger_dma(self, transfer_length):
        self.fpga.dma_mm_to_st.configure(transfer_length)
        self.fpga.dma_st_to_mm.configure(transfer_length)
        self.fpga.dma_st_to_mm.trigger()
        self.fpga.dma_mm_to_st.trigger()
        self.fpga.dma_st_to_mm.measure_bandwidth()

    def tea_enable(self):
        tea_enable_offset = 0x1
        self.fpga.write(self.fpga.csr_addr + 0x004, (1 << tea_enable_offset).to_bytes(1, 'little'))

    def set_tea_mode(self, mode):
        tea_enable_offset = 0x1
        tea_mode_offset = 0x2
        control_register_value = (1 << tea_enable_offset)

        if mode == 'decode':
            control_register_value |= (1 << tea_mode_offset)

        self.fpga.write(self.fpga.csr_addr + 0x004, control_register_value.to_bytes(1, 'little'))

    def test_hps_write_ocm(self):
        with open('/usr/bin/dsp/data/data_to_send_32kB.txt', 'rb') as fd:
            data = fd.read()

        self.fpga.ocm1.write(data)

        read_buff = self.fpga.ocm1.read(len(data))

        self.assertEqual(read_buff.decode(), data.decode())

    def test_dma_memory_write_memory(self):
        with open('/usr/bin/dsp/data/data_to_send_32kB.txt', 'rb') as fd:
            data = fd.read()
        transfer_length = len(data)

        self.fpga.ocm1.write(data)
        self.configure_and_trigger_dma(transfer_length)

        read_buff = self.fpga.ocm2.read(len(data))

        self.assertEqual(read_buff.decode(), data.decode())

    def test_csr_write(self):
        data_sizes = [1, 2, 4, 8]
        ranges = [(self.fpga.csr_addr, self.fpga.csr_addr + 0x8), (self.fpga.csr_addr + 0x100, self.fpga.csr_addr + 0x140)]

        for data_size in data_sizes:
            exp_data_dict = {}

            for start_addr, end_addr in ranges:
                for address in range(start_addr, end_addr, data_size):
                    data = bytes(random.getrandbits(8) for _ in range(data_size))
                    exp_data_dict[address] = data
                    self.fpga.write(address, data)

            for address, exp_data in exp_data_dict.items():
                read_data = self.fpga.read(address, len(exp_data))
                self.assertEqual(read_data, exp_data, f"transfer length: {len(exp_data)}, address: {hex(address)}")

    def test_tea(self):
        self.tea_enable()
        self.set_tea_mode('decode')

        with wave.open('/usr/bin/dsp/data/sine_wave_10Hz_100Hz.wav', 'rb') as wav_file:
            num_channels = wav_file.getnchannels()
            sample_width = wav_file.getsampwidth()
            num_frames = wav_file.getnframes()
            data = wav_file.readframes(num_frames)

        transfer_length = (num_frames * num_channels * sample_width) * 2

        data = (np.frombuffer(data, dtype=np.int16)).astype(np.int32)
        data_bytes = data.tobytes()

        self.fpga.ocm1.write(data_bytes)
        self.configure_and_trigger_dma(transfer_length)

        encoded_read_data_bytes = self.fpga.ocm2.read(len(data_bytes))

        self.fpga.dma_st_to_mm.clear_control_register()
        self.fpga.dma_mm_to_st.clear_control_register()

        self.set_tea_mode('encode')

        self.fpga.ocm1.write(encoded_read_data_bytes)
        self.configure_and_trigger_dma(transfer_length)

        decoded_read_data_bytes = self.fpga.ocm2.read(len(data_bytes))
        decoded_data = np.frombuffer(decoded_read_data_bytes, dtype=np.int32)

        self.assertTrue(np.array_equal(decoded_data, data))


unittest.main()
