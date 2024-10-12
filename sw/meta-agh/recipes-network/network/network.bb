LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := "file://end0_config"

do_install:append() {
    install -d ${D}${libdir}/systemd/network
    install -m 0755 ${WORKDIR}/end0_config ${D}${libdir}/systemd/network/10-end0.network
}

FILES:${PN} += "${libdir}/systemd/network/*"
