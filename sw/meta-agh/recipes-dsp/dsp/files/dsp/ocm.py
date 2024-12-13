import ctypes
import time

class OCM:
    def __init__(self, mem, ocm_indicator):
        offset_map = {1: 0x00000000, 2: 0x00020000}
        self.offset = offset_map[ocm_indicator]
        self.mem = mem

    def write(self, data, offset=0):
        self.mem.seek(self.offset + offset)
        self.mem.write(data)

    def read(self, size, offset=0):
        self.mem.seek(self.offset + offset)
        return self.mem.read(size)

