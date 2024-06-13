import ocm
import dma
import mmap
import os

class FPGA:
    def __init__(self):
        self.mem_size = 0x00050000 #0x00040000
        self.lwfpgaslaves_addr = 0xff200000
        self.dev = "/dev/mem"
        self.fd = os.open(self.dev, os.O_RDWR | os.O_SYNC)
        self.mem = mmap.mmap(self.fd, self.mem_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=self.lwfpgaslaves_addr)

        self.dma = dma.DMA(self)
        self.ocm1 = ocm.OCM(self, 1)
        self.ocm2 = ocm.OCM(self, 2)

    def read(self, address, size):
        self.mem.seek(address)
        return self.mem.read(size)

    def write(self, address, data):
        self.mem.seek(address)
        self.mem.write(data)

    def clear_memory(self):
        self.write(0, b'\0' * self.mem_size)

    def close(self):
        self.mem.close()
        os.close(self.fd)

