import argparse
import fpga

fpga_instance = fpga.FPGA()
size= 1

def led_control(led_index, led_enable):
    value = 1 << led_index
    current_value = int.from_bytes(fpga_instance.read(fpga_instance.csr_addr, size), 'little')

    if(led_enable):
        current_value |= value
        print(f"LED State: {led_index} on")
    else:
        current_value &= ~value
        print(f"LED State: {led_index} off")

    fpga_instance.write(fpga_instance.csr_addr, current_value.to_bytes(size, 'little'))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('led_index', type=int)
    parser.add_argument('led_enable', type=str)

    args = parser.parse_args()
    led_enable = args.led_enable.lower() == 'true'
    led_control(args.led_index, led_enable)