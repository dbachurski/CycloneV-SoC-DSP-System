import unittest
import fpga
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

    def test_hps_write_ocm(self):
        with open('/usr/bin/dsp/data/data_to_send_64kB.txt', 'rb') as fd:
            data = fd.read()

        self.fpga.ocm1.write(data)

        read_buff = self.fpga.ocm1.read(len(data))

        self.assertEqual(read_buff.decode(), data.decode())

    def test_dma_memory_write_memory(self):
        with open('/usr/bin/dsp/data/data_to_send_64kB.txt', 'rb') as fd:
            data = fd.read()
        transfer_length = len(data)

        self.fpga.ocm1.write(data)

        self.fpga.dma_mm_to_st.configure(transfer_length)
        self.fpga.dma_st_to_mm.configure(transfer_length)

        self.fpga.dma_st_to_mm.trigger()
        self.fpga.dma_mm_to_st.trigger()

        self.fpga.dma_st_to_mm.measure_bandwidth()

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


unittest.main()