import unittest
import fpga
import dma

class TestStringMethods(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.fpga = fpga.FPGA()
        cls.dma = dma.DMA()

    @classmethod
    def tearDownClass(cls):
        cls.fpga.close()

    def tearDown(self):
        self.fpga.clear_memory()


    def test_hps_write_ocm(self):
        text = "test fpga"

        self.fpga.write(self.fpga.ocm_offset, text.encode())

        read_buff = self.fpga.read(self.fpga.ocm_offset, len(text))
        read_buff = read_buff.decode()

        self.assertEqual(read_buff, text)
    

    def test_dma_memory_write_memory(self):
        text = "test fpga"
        transfer_length = 10
    
        self.fpga.write(self.fpga.ocm_offset, text.encode())

        self.dma.send_descriptor(self.fpga.ocm2_offset, self.fpga.ocm_offset, transfer_length)
        read_buff = self.fpga.read(self.fpga.ocm2_offset, len(text))
        read_buff = read_buff.decode()

        self.assertEqual(read_buff, text)


unittest.main()