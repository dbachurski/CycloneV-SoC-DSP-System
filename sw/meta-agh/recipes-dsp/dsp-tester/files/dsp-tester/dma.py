import ctypes
import time
import math

class DMA:
    def __init__(self, fpga_instance, dma_indicator):
        offset_map = {1: [0x00050000, 0x0051000], 2: [0x00052000, 0x0053000], }
        self.csr_offset = offset_map[dma_indicator][0]
        self.descriptor_offset = offset_map[dma_indicator][1]
        self.dma_indicator = dma_indicator
        self.read_addr_offset = self.descriptor_offset + 0x0
        self.write_addr_offset = self.descriptor_offset + 0x4
        self.length_offset = self.descriptor_offset + 0x8
        self.control_register_offset = self.descriptor_offset + 0xC
        self.status_register_offset = self.csr_offset
        self.register_size = 0x4
        self.fpga = fpga_instance

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

    def trigger(self, transfer_length):
        read_address = self.fpga.ocm1.offset
        write_address = self.fpga.ocm2.offset
        control_register = DMA.ControlRegister()

        self.fpga.write(self.read_addr_offset, read_address.to_bytes(4, 'little'))
        self.fpga.write(self.write_addr_offset, write_address.to_bytes(4, 'little'))
        self.fpga.write(self.length_offset, transfer_length.to_bytes(4, 'little'))

        if(self.dma_indicator == 1):
            control_register.generate_sop = 1
            control_register.generate_eop = 1
            control_register_bytes = ctypes.string_at(ctypes.byref(control_register), self.register_size)
            self.fpga.write(self.control_register_offset, control_register_bytes)

        control_register.go = 1
        control_register_bytes = ctypes.string_at(ctypes.byref(control_register), self.register_size)
        self.fpga.write(self.control_register_offset, control_register_bytes)

        if(self.dma_indicator == 2):
            start_time = time.perf_counter()
            dma_busy = ((self.fpga.read(self.status_register_offset, 1))[0]) & 1

            while dma_busy:
                dma_busy = ((self.fpga.read(self.status_register_offset, 1))[0]) & 1
            end_time = time.perf_counter()

            transfer_length = math.ceil(transfer_length / 4) * 4
            bandwidth = (transfer_length / (end_time - start_time)) / 2**20

            print(f"time: {end_time - start_time:.10f} s")
            print(f"DMA bandwidth: {bandwidth:.4f} MB/s")


