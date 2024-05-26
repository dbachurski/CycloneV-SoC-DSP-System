LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
 
FILESEXTRAPATHS:append := "${THISDIR}/files:"
 
SRC_URI:append := " \
    file://setup.py \
    file://dsp-tester/__init__.py \
    file://dsp-tester/fpga.py \
    file://dsp-tester/dma.py \
    file://dsp-tester/main.py \
"
 
S = "${WORKDIR}"
 
inherit setuptools3
 
RDEPENDS_${PN} = "python3"
 
do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/dsp-tester/main.py ${D}${bindir}/dsp-tester

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    install -m 0755 ${S}/dsp-tester/fpga.py ${D}${PYTHON_SITEPACKAGES_DIR}/fpga.py
    install -m 0755 ${S}/dsp-tester/dma.py ${D}${PYTHON_SITEPACKAGES_DIR}/dma.py
}


