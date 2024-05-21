import unittest
import fpga

fpga = fpga.FPGA()
class TestStringMethods(unittest.TestCase):

    def test_hps_write_ocm(self):
        text = "hello world"
        fpga.write(fpga.ocm_offset, text)
        read_buff = fpga.read(fpga.ocm_offset, len(text))
        self.assertEqual(read_buff, text)

unittest.main()
