# CycloneV-SoC-DSP-System

## Clone repository
```bash
git clone --recursive git@github.com:dbachurski/CycloneV-SoC-DSP-System.git
```

### PeakRDL installation
```bash
python3 -m pip install peakrdl
```

## Device programming

### Interactive subshell initialization
```bash
./env.sh
```

### FPGA bitfile generation
```bash
hw_generator.sh
```

### System image generation
```bash
bitbake agh-image-base
```

### SD card preparation
To prepare an SD card, write to it a generated system image file
(`./sw/build/tmp/deploy/images/de0-nano-soc/agh-image-base-de0-nano-soc.wic`).

### Board preparation
Before powering up a device, confirm that `MSEL` pins (`SW10`) are set to `6'b0`. Then plug-in the
SD card and connect a USB cable to the `J4` connector (it enables serial port data transmission).

### Linux login prompt
You can access the Linux prompt via serial connection using username `root`. Password is not
required.

## Simulations

### Simulation execution (command line mode)
```bash
sim_runner.sh -t <test_name>
```

### Simulation execution (with GUI)
```bash
sim_runner.sh -gt <test_name>
```
