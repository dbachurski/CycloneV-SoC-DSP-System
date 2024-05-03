#!/bin/bash -e

cd ${ROOTDIR}/hw
git clean -fXd .

peakrdl regblock rdl/agh_socfpga.rdl \
    -o rtl/agh_socfpga \
    --peakrdl-cfg rdl/peakrdl.toml \
    --cpuif avalon-mm-flat \
    --addr-width 12

cd ${ROOTDIR}/hw/fpga
quartus_sh --flow compile de0_nano_soc
quartus_cpf -c de0_nano_soc.cof

cd ${ROOTDIR}/hw
mkdir -p bsp
peakrdl c-header rdl/agh_socfpga.rdl \
    -o bsp/agh_socfpga.h \
    --peakrdl-cfg rdl/peakrdl.toml
