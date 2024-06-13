import ctypes
import time

class OCM:
    def __init__(self, fpga_instance, ocm_indicator):
        offset_map = {1: 0x00000000, 2: 0x00020000} #{1: 0x00000000, 2: 0x00010000}
        self.offset = offset_map[ocm_indicator]
        self.fpga = fpga_instance

    def write(self, data, offset=0):
        self.fpga.mem.seek(self.offset + offset)
        self.fpga.mem.write(data)

    def read(self, size, offset=0):
        self.fpga.mem.seek(self.offset + offset)
        return self.fpga.mem.read(size)

