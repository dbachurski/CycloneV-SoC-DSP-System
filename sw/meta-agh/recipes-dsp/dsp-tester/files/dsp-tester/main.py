import unittest
import fpga

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
        with open('data_to_send_64kB.txt', 'rb') as fd:
            data = fd.read()

        self.fpga.ocm1.write(data)

        read_buff = self.fpga.ocm1.read(len(data))

        self.assertEqual(read_buff.decode(), data.decode())

    def test_dma_memory_write_memory(self):
        with open('data_to_send_64kB.txt', 'rb') as fd:
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


unittest.main()