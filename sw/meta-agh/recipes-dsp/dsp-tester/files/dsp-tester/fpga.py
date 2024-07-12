import dma, dma_mm_to_st, dma_st_to_mm
import ocm
import mmap
import os

class FPGA:
    def __init__(self):
        self.mem_size = 0x00060000
        self.lwfpgaslaves_addr = 0xff200000
        self.dev = "/dev/mem"
        self.fd = os.open(self.dev, os.O_RDWR | os.O_SYNC)
        self.mem = mmap.mmap(self.fd, self.mem_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=self.lwfpgaslaves_addr)

        self.ocm1 = ocm.OCM(self, 1)
        self.ocm2 = ocm.OCM(self, 2)
        self.dma = dma.DMA()
        self.dma_mm_to_st = dma_mm_to_st.DMA_MM_TO_ST(self, self.dma)
        self.dma_st_to_mm = dma_st_to_mm.DMA_ST_TO_MM(self, self.dma)

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

