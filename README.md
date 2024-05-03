# 2025_eng_dbachurski

## Clone repository
```bash
git clone --recursive git@github.com:agh-riscv/2025_eng_dbachurski.git
```

## Build server configuration
If you want to develop your project using _cadence62_ or _cadence213_ server, you need to change
the used _Python3_ version. Execute the following commands to configure the environment:
```bash
mkdir -p ~/bin
cd ~/bin

ln -s /usr/local/bin/2to3-3.11 2to3
ln -s /usr/local/bin/idle3.11 idle3
ln -s /usr/bin/pydoc pydoc
ln -s /usr/local/bin/pydoc3.11 pydoc3
ln -s /usr/local/bin/python3.11 python3
ln -s /usr/local/bin/python3.11-config python3-config
```
and add the following lines to your `.bashrc` file:
```bash
export PATH=~/bin:/usr/local/bin:/scratch/${USER}/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/:/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}
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
To prepare an SD card, download a generated system image file
(`./sw/build/tmp/deploy/images/de0-nano-soc/agh-image-base-de0-nano-soc.wic`)
on your local machine using e.g. `scp`. Then write this file to the SD card using
[_Win32 Disk Imager_](http://sourceforge.net/projects/win32diskimager/) or `dd`.

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
