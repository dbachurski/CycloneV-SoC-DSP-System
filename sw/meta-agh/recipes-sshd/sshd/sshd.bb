LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := "file://custom_sshd.conf"

do_install:append() {
    install -d ${D}/etc/ssh/sshd_config.d
    install -m 0644 ${WORKDIR}/custom_sshd.conf ${D}/etc/ssh/sshd_config.d/custom_sshd.conf
}

# FILES:${PN} += "${libdir}/systemd/network/*"
