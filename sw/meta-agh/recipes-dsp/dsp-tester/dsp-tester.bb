LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := " \
    file://setup.py \
    file://dsp-tester/__init__.py \
    file://dsp-tester/fpga.py \
    file://dsp-tester/dma.py \
    file://dsp-tester/dma_mm_to_st.py \
    file://dsp-tester/dma_st_to_mm.py \
    file://dsp-tester/ocm.py \
    file://dsp-tester/main.py \
    file://dsp-tester/data/data_to_send.txt \
    file://dsp-tester/data/data_to_send_64kB.txt \
"

S = "${WORKDIR}"

inherit setuptools3

RDEPENDS_${PN} = "python3"

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/dsp-tester/main.py ${D}${bindir}/dsp-tester
    install -m 0755 ${S}/dsp-tester/data/data_to_send.txt ${D}${bindir}/data_to_send.txt
    install -m 0755 ${S}/dsp-tester/data/data_to_send_64kB.txt ${D}${bindir}/data_to_send_64kB.txt

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    install -m 0755 ${S}/dsp-tester/fpga.py ${D}${PYTHON_SITEPACKAGES_DIR}/fpga.py
    install -m 0755 ${S}/dsp-tester/dma.py ${D}${PYTHON_SITEPACKAGES_DIR}/dma.py
    install -m 0755 ${S}/dsp-tester/dma_mm_to_st.py ${D}${PYTHON_SITEPACKAGES_DIR}/dma_mm_to_st.py
    install -m 0755 ${S}/dsp-tester/dma_st_to_mm.py ${D}${PYTHON_SITEPACKAGES_DIR}/dma_st_to_mm.py
    install -m 0755 ${S}/dsp-tester/ocm.py ${D}${PYTHON_SITEPACKAGES_DIR}/ocm.py
}



