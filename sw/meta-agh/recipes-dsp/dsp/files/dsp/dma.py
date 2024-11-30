import ctypes

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
