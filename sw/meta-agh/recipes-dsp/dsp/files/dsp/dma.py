import ctypes
import time
import math

class DMA:
    def __init__(self):
        self.read_addr_offset = 0x0
        self.write_addr_offset = 0x4
        self.length_offset = 0x8
        self.control_register_offset = 0xC
        self.register_size = 0x4
        self.control_register = DMA.ControlRegister()

    class ControlRegister(ctypes.LittleEndianStructure):
        _fields_ = [
            ("transmit_channel", ctypes.c_ubyte, 8),
            ("generate_sop", ctypes.c_ubyte, 1),
            ("generate_eop", ctypes.c_ubyte, 1),
            ("park_reads", ctypes.c_ubyte, 1),
            ("park_writes", ctypes.c_ubyte, 1),
            ("end_on_eop", ctypes.c_ubyte, 1),
            ("reserved1", ctypes.c_ubyte, 1),
            ("transfer_complete", ctypes.c_ubyte, 1),
            ("early_termination", ctypes.c_ubyte, 1),
            ("transmit_error", ctypes.c_ubyte, 8),
            ("early_done_enable", ctypes.c_ubyte, 1),
            ("wait_write_response", ctypes.c_ubyte, 1),
            ("reserved2", ctypes.c_ubyte, 5),
            ("go", ctypes.c_ubyte, 1)
        ]
        _pack_ = 1

class DMA_MM_TO_ST(DMA):
    def __init__(self, mem):
        super().__init__()
        self.mem = mem
        self.csr_offset = 0x00050000
        self.descriptor_offset = 0x0051000
        self.read_address = 0x00000000
        self.read_addr_offset = self.descriptor_offset + self.read_addr_offset
        self.length_offset = self.descriptor_offset + self.length_offset
        self.control_register_offset = self.descriptor_offset + self.control_register_offset

    def configure(self, transfer_length):
        self.mem.seek(self.read_addr_offset)
        self.mem.write(self.read_address.to_bytes(4, 'little'))
        self.mem.seek(self.length_offset)
        self.mem.write(transfer_length.to_bytes(4, 'little'))

    def trigger(self):
        self.control_register.generate_sop = 1
        self.control_register.generate_eop = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.register_size)
        self.mem.seek(self.control_register_offset)
        self.mem.write(self.control_register_bytes)

        self.control_register.go = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.register_size)
        self.mem.seek(self.control_register_offset)
        self.mem.write(self.control_register_bytes)

    def clear_control_register(self):
        self.control_register.generate_sop = 0
        self.control_register.generate_eop = 0
        self.control_register.go = 0

class DMA_ST_TO_MM(DMA):
    def __init__(self, mem):
        super().__init__()
        self.mem = mem
        self.csr_offset = 0x00052000
        self.descriptor_offset = 0x0053000
        self.write_address = 0x00020000
        self.write_addr_offset = self.descriptor_offset + self.write_addr_offset
        self.length_offset = self.descriptor_offset + self.length_offset
        self.control_register_offset = self.descriptor_offset + self.control_register_offset
        self.status_register_offset = self.csr_offset

    def configure(self, transfer_length):
        self.transfer_length = transfer_length
        self.mem.seek(self.write_addr_offset)
        self.mem.write(self.write_address.to_bytes(4, 'little'))
        self.mem.seek(self.length_offset)
        self.mem.write(self.transfer_length.to_bytes(4, 'little'))

    def trigger(self):
        self.control_register.go = 1
        self.control_register_bytes = ctypes.string_at(ctypes.byref(self.control_register), self.register_size)
        self.mem.seek(self.control_register_offset)
        self.mem.write(self.control_register_bytes)

    def monitor(self):
        start_time = time.perf_counter()
        self.mem.seek(self.status_register_offset)
        dma_busy = (self.mem.read(1)[0]) & 1

        while dma_busy:
            self.mem.seek(self.status_register_offset)
            dma_busy = (self.mem.read(1)[0]) & 1

        end_time = time.perf_counter()
        transfer_length = math.ceil(self.transfer_length / 4) * 4
        bandwidth = (transfer_length / (end_time - start_time)) / 2**20

        return bandwidth

    def clear_control_register(self):
        self.control_register.go = 0
