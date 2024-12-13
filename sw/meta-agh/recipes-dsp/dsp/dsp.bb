LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := "file://dsp \
                   file://setup.py"

S = "${WORKDIR}"

inherit setuptools3

RDEPENDS_${PN} = "python3"

do_install:append() {
    install -d ${D}${bindir}/dsp/apps
    install -d ${D}${bindir}/dsp/data
    install -d ${D}${bindir}/dsp/output
    install -m 0755 ${S}/dsp/dsp_tester.py ${D}${bindir}/dsp/apps/dsp-tester
    install -m 0755 ${S}/dsp/dsp_controller.py ${D}${bindir}/dsp/apps/dsp-controller
    install -m 0755 ${S}/dsp/led_controller.py ${D}${bindir}/dsp/apps/led-controller
    install -m 0755 ${S}/dsp/data/data_to_send_32kB.txt ${D}${bindir}/dsp/data/data_to_send_32kB.txt
    install -m 0755 ${S}/dsp/data/sine_wave_10Hz_100Hz.wav ${D}${bindir}/dsp/data/sine_wave_10Hz_100Hz.wav
    install -m 0755 ${S}/dsp/data/noisy_signal.wav ${D}${bindir}/dsp/data/noisy_signal.wav
    install -m 0755 ${S}/dsp/data/moving_average.txt ${D}${bindir}/dsp/data/moving_average.txt
    install -m 0755 ${S}/dsp/data/unit_impulse.txt ${D}${bindir}/dsp/data/unit_impulse.txt

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    install -m 0755 ${S}/dsp/fpga.py ${D}${PYTHON_SITEPACKAGES_DIR}/fpga.py
    install -m 0755 ${S}/dsp/dma.py ${D}${PYTHON_SITEPACKAGES_DIR}/dma.py
    install -m 0755 ${S}/dsp/ocm.py ${D}${PYTHON_SITEPACKAGES_DIR}/ocm.py
}



