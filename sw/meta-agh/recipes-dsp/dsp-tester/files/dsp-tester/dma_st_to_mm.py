import ctypes
import time
import math

class DMA_ST_TO_MM:
    def __init__(self, fpga_instance, dma_instance):
        self.dma = dma_instance
        self.fpga = fpga_instance
        self.csr_offset = 0x00052000
        self.descriptor_offset = 0x0053000
        self.write_addr_offset = self.descriptor_offset + self.dma.write_addr_offset
        self.length_offset = self.descriptor_offset + self.dma.length_offset
        self.control_register_offset = self.descriptor_offset + self.dma.control_register_offset
        self.control_register = self.dma.control_register
        self.status_register_offset = self.csr_offset
        self.write_address = self.fpga.ocm2.offset

    def configure(self, transfer_length):
        self.transfer_length = transfer_length
        self.fpga.write(self.write_addr_offset, self.write_address.to_bytes(4, 'little'))
        self.fpga.write(self.length_offset, self.transfer_length.to_bytes(4, 'little'))

    def trigger(self):
        self.control_register.go = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.dma.register_size)
        self.fpga.write(self.control_register_offset, self.control_register_bytes)

    def measure_bandwidth(self):
        start_time = time.perf_counter()
        dma_busy = ((self.fpga.read(self.status_register_offset, 1))[0]) & 1

        while dma_busy:
            dma_busy = ((self.fpga.read(self.status_register_offset, 1))[0]) & 1
        end_time = time.perf_counter()

        transfer_length = math.ceil(self.transfer_length / 4) * 4
        bandwidth = (transfer_length / (end_time - start_time)) / 2**20

        print(f"time: {end_time - start_time:.10f} s")
        print(f"DMA bandwidth: {bandwidth:.4f} MB/s")


