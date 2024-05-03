LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := " \
    file://agh_socfpga.h \
"

S = "${WORKDIR}"

PROVIDES += "agh-socfpga-bsp"

do_install() {
    install -d ${D}${includedir}
    install -m 0644 ${S}/agh_socfpga.h ${D}${includedir}
}
