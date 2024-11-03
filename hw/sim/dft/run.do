vlib work
vmap work ./work

vlog -l compile.log \
    -f ${VERIFICATION_IP_ROOTDIR}/svunit.f \
    /home/domin/intelFPGA_lite/23.1std/quartus/eda/sim_lib/altera_mf \
    dft_unit_test.sv

vsim -L altera_mf -L /home/domin/intelFPGA_lite/23.1std/quartus/eda/sim_lib/altera_mf dft_unit_test

runSVUnit -s questa