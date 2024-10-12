LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI:append := "file://myserver \
                   file://server \
                   file://data \
                   file://manage.py \
                   file://db.sqlite3 \
                   file://setup.py \
                   file://dsp.service "

S = "${WORKDIR}"

inherit setuptools3
inherit systemd

RDEPENDS_${PN} += "python3 python3-django python3-numpy python3-matplotlib"

do_install:append() {
    install -d ${D}${bindir}/django-server/server
    find ${S}/server -type f | while read -r file; do
        relative_path="${file#${S}/server/}"
        install -D -m 0755 "$file" "${D}${bindir}/django-server/server/$relative_path"
    done

    install -d ${D}${bindir}/django-server/myserver
    find ${S}/myserver -type f | while read -r file; do
        relative_path="${file#${S}/myserver/}"
        install -D -m 0755 "$file" "${D}${bindir}/django-server/myserver/$relative_path"
    done

    install -d ${D}${bindir}/django-server/data
    install -m 0755 ${S}/data/empty_plot.svg ${D}${bindir}/django-server/data/empty_plot.svg

    install -m 0755 ${S}/manage.py ${D}${bindir}/django-server/manage.py
    install -m 0755 ${S}/db.sqlite3 ${D}${bindir}/django-server/db.sqlite3

    install -d ${D}${systemd_system_unitdir}
    install -m 0755 ${S}/dsp.service ${D}${systemd_system_unitdir}/dsp.service
}

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "dsp.service"

