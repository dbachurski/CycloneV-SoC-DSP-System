import mmap
import os

class FPGA:
    def __init__(self):
        self.mem_size = 0x00040000
        self.lwfpgaslaves_addr = 0xff200000
        self.ocm_offset = 0x00000000
        self.ocm2_offset = 0x00010000
        self.dev = "/dev/mem"
        self.max_data_lenght = 65535
        self.fd = os.open(self.dev, os.O_RDWR | os.O_SYNC)
        self.mem = mmap.mmap(self.fd, self.mem_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=lwfpgaslaves_addr)

    def read(self, address, size, buff):
        self.mem.seek(address)
        return self.mem.read(size).decode()

    def write(self, address, data):
        data = data.encode()
        self.mem.seek(address)
        self.mem.write(data)

    def close(self):
        self.mem.close()
        os.close(self.fd)
