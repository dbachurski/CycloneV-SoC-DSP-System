#!/bin/bash -e

if [[ "$0" != "${BASH_SOURCE}" ]]; then
    echo "ERROR: script cannot be sourced"
    exit
fi

case $(hostname) in
    "cadence62")
        export INTEL_FPGA_ROOTDIR=/scratch/Intel/intelFPGA_lite/22.1std
        ;;
    "cadence213")
        export INTEL_FPGA_ROOTDIR=/opt/intelFPGA_lite/22.1std
        ;;
    "asusprime")
        export INTEL_FPGA_ROOTDIR=/opt/intelFPGA_lite/23.1std
        ;;
    "fedora")
        export INTEL_FPGA_ROOTDIR=/home/domin/intelFPGA_lite/23.1std
        ;;
    *)
        echo "ERROR: unsupported host"
        exit 1
esac

. etc/git-prompt.sh

export QUARTUS_ROOTDIR=${INTEL_FPGA_ROOTDIR}/quartus
export QUESTA_ROOTDIR=${INTEL_FPGA_ROOTDIR}/questa_fse
export VERIFICATION_IP_ROOTDIR=${INTEL_FPGA_ROOTDIR}/ip/altera/sopc_builder_ip/verification
export LM_LICENSE_FILE=${QUESTA_ROOTDIR}/licenses/LR-174075_License.dat

export ROOTDIR=$(pwd)
export SVUNIT_INSTALL=${ROOTDIR}/deps/svunit
export PATH=${ROOTDIR}/tools:${QUARTUS_ROOTDIR}/bin:${QUESTA_ROOTDIR}/bin:${SVUNIT_INSTALL}:${PATH}

export GIT_PS1_SHOWDIRTYSTATE=1
export GREEN="\033[01;32m"
export RED="\033[0;31m"
export WHITE="\033[00m"

_sim_runner_completions() {
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "-a -gt -l -t" -- "${COMP_WORDS[1]}"))
    elif [[ ${COMP_CWORD} -eq 2 && ${COMP_WORDS[1]} =~ ^(-gt|-t) ]]; then
        COMPREPLY=($(compgen -W "$(ls ${ROOTDIR}/hw/sim)" -- "${COMP_WORDS[2]}"))
    fi
}

git_branch_name() {
    BRANCH_NAME=$(__git_ps1 " (%s)")

    if [[ ${BRANCH_NAME} =~ "*" ]]; then
        BRANCH_COLOR=${RED}
    else
        BRANCH_COLOR=${GREEN}
    fi

    BRANCH_NAME=${BRANCH_COLOR}${BRANCH_NAME/\ \*)/)}
    echo -e "${BRANCH_NAME} ${WHITE}"
}

export -f __git_eread
export -f __git_ps1
export -f __git_sequencer_status
export -f _sim_runner_completions
export -f git_branch_name

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(git_branch_name)\n$ '

cd ${SVUNIT_INSTALL}
. Setup.bsh

cd ${ROOTDIR}/sw
. poky/oe-init-build-env build

if [[ ! -e conf/site.conf ]]; then
    cat <<-EOF > conf/site.conf
DISTRO = "agh-poky"
MACHINE = "de0-nano-soc"
DL_DIR = "\${TOPDIR}/../downloads"
SSTATE_DIR = "\${TOPDIR}/../sstate_cache"
EOF

    cat <<-EOF >> conf/bblayers.conf
BBLAYERS += " \\
    \${TOPDIR}/../meta-agh \\
    \${TOPDIR}/../meta-intel-fpga \\
    \${TOPDIR}/../meta-openembedded/meta-oe \\
    \${TOPDIR}/../meta-openembedded/meta-python \\
"
EOF

    if [[ $(hostname) == "cadence62" ]]; then
        ln -sf /usr/local/bin/git-upload-pack ../poky/scripts/

        echo 'BB_NUMBER_THREADS = "16"' >> conf/local.conf
        echo 'PARALLEL_MAKE = "-j 16"' >> conf/local.conf
    elif [[ $(hostname) == "cadence213" ]]; then
        echo 'PARALLEL_MAKE = "-j 1"' >> conf/local.conf
    fi
fi

cd ${ROOTDIR}

bash --init-file <(echo " \
    complete -F _sim_runner_completions sim_runner.sh; \
")