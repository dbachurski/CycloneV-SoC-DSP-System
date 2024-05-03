FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := " \
    file://defconfig \
"

unset KBUILD_DEFCONFIG
KERNEL_DEFCONFIG = "${WORKDIR}/defconfig"
