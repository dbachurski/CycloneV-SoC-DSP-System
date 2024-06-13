LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := " \
    file://setup.py \
    file://dsp-tester/__init__.py \
    file://dsp-tester/fpga.py \
    file://dsp-tester/dma.py \
    file://dsp-tester/ocm.py \
    file://dsp-tester/main.py \
    file://dsp-tester/data/data_to_send.txt \
"

S = "${WORKDIR}"

inherit setuptools3

BBCLASSEXTEND = "native"

RDEPENDS_${PN} = "python3"

DEPENDS = "python3-cython-native"

do_compile:prepend() {
    cp ${S}/dsp-tester/dma.py ${S}
    cp ${S}/dsp-tester/fpga.py ${S}
    cp ${S}/dsp-tester/ocm.py ${S}
}

do_compile:append() {
    ${STAGING_BINDIR_NATIVE}/python3-native/python3 ${S}/setup.py build_ext --inplace
}

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/dsp-tester/main.py ${D}${bindir}/dsp-tester
    install -m 0755 ${S}/dsp-tester/data/data_to_send.txt ${D}${bindir}/data_to_send.txt

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    install -m 0755 ${B}/dma.cpython-*.so ${D}${PYTHON_SITEPACKAGES_DIR}/dma.so
    install -m 0755 ${B}/fpga.cpython-*.so ${D}${PYTHON_SITEPACKAGES_DIR}/fpga.so
    install -m 0755 ${B}/ocm.cpython-*.so ${D}${PYTHON_SITEPACKAGES_DIR}/ocm.so
}



