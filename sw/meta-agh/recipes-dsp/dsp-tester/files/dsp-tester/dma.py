import fpga
import ctypes
import time

class DMA:
    def __init__(self):
        self.dma_offset = 0x00031000
        self.dma_read_addr_offset = self.dma_offset + 0x0
        self.dma_write_addr_offset = self.dma_offset + 0x4
        self.dma_length_offset = self.dma_offset + 0x8
        self.dma_control_addr_offset = self.dma_offset + 0xC
        self.fpga = fpga.FPGA()

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

    class StatusRegister(ctypes.LittleEndianStructure):
        _fields_ = [
            ("busy", ctypes.c_uint32, 1),
            ("descriptor_buffer_empty", ctypes.c_uint32, 1),
            ("descriptor_buffer_full", ctypes.c_uint32, 1),
            ("response_buffer_empty", ctypes.c_uint32, 1),
            ("response_buffer_full", ctypes.c_uint32, 1),
            ("stopped", ctypes.c_uint32, 1),
            ("resetting", ctypes.c_uint32, 1),
            ("stopped_on_error", ctypes.c_uint32, 1),
            ("stopped_on_early_termination", ctypes.c_uint32, 1),
            ("irq", ctypes.c_uint32, 1),
            ("reserved", ctypes.c_uint32, 22)
        ]
        _pack_ = 1

    def check_status_register(self, status_register, status_register_size):

        status_register_bytes = self.fpga.read(self.dma_csr_status_register_offset, status_register_size)
        ctypes.memmove(ctypes.byref(status_register), status_register_bytes, status_register_size)

    def send_descriptor(self, write_address, read_address, transfer_length):

        control_register = DMA.ControlRegister()
        status_register = DMA.StatusRegister()

        control_register_size = ctypes.sizeof(control_register)
        control_register_bytes = ctypes.string_at(ctypes.byref(control_register), control_register_size)

        status_register_size = ctypes.sizeof(status_register)

        self.fpga.write(self.dma_read_addr_offset, read_address.to_bytes(4, 'little'))
        self.fpga.write(self.dma_write_addr_offset, write_address.to_bytes(4, 'little'))
        self.fpga.write(self.dma_length_offset, transfer_length.to_bytes(4, 'little'))

        control_register.go = 1
        control_register_bytes = ctypes.string_at(ctypes.byref(control_register), control_register_size)
        self.fpga.write(self.dma_control_addr_offset, control_register_bytes)

        start_time = time.perf_counter()
        while status_register.busy:
            self.check_status_register(status_register, status_register_size)
        end_time = time.perf_counter()
        capacity = (transfer_length / (end_time - start_time)) / 1048576

        return capacity


