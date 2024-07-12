import ctypes
import copy

class DMA_MM_TO_ST:
    def __init__(self, fpga_instance, dma_instance):
        self.dma = dma_instance
        self.fpga = fpga_instance
        self.csr_offset = 0x00050000
        self.descriptor_offset = 0x0051000
        self.read_addr_offset = self.descriptor_offset + self.dma.read_addr_offset
        self.length_offset = self.descriptor_offset + self.dma.length_offset
        self.control_register_offset = self.descriptor_offset + self.dma.control_register_offset
        self.control_register = copy.deepcopy(self.dma.control_register)
        self.read_address = self.fpga.ocm1.offset

    def configure(self, transfer_length):
        self.fpga.write(self.read_addr_offset, self.read_address.to_bytes(4, 'little'))
        self.fpga.write(self.length_offset, transfer_length.to_bytes(4, 'little'))

    def trigger(self):
        self.control_register.generate_sop = 1
        self.control_register.generate_eop = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.dma.register_size)
        self.fpga.write(self.control_register_offset, self.control_register_bytes)

        self.control_register.go = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.dma.register_size)
        self.fpga.write(self.control_register_offset, self.control_register_bytes)



