FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := " \
    file://bootcmd.cfg \
    file://de0_nano_soc.rbf \
    file://hps_isw_handoff \
    file://netboot.patch \
    file://u-boot.txt \
"

do_compile:prepend() {
    python3 ${WORKDIR}/git/arch/arm/mach-socfpga/cv_bsp_generator/cv_bsp_generator.py \
        -i ${WORKDIR}/hps_isw_handoff/de0_nano_soc_hps \
        -o ${WORKDIR}/git/board/altera/cyclone5-socdk/qts

    mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Cyclone5 script" \
        -d  ${WORKDIR}/u-boot.txt  ${WORKDIR}/u-boot.scr
}

do_deploy:append() {
    install -m 644 ${WORKDIR}/de0_nano_soc.rbf ${DEPLOYDIR}
    install -m 644 ${WORKDIR}/u-boot.scr ${DEPLOYDIR}
}
