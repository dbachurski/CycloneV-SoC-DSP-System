#!/bin/bash -e
#
# Copyright (C) 2023  AGH University of Science and Technology
#

function usage {
    echo "usage: $(basename "$0") [options]"
    echo "  options:"
    echo "      -g,     show GUI"
    echo "      -l,     list available tests"
    echo "      -t,     specify the test name"
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi

while getopts glt: option; do
    case ${option} in
        g) gui=1;;
        l) list_available_test=1;;
        t) test_name=${OPTARG};;
        *) usage;;
    esac
done

cd ${ROOTDIR}/hw/sim

if [[ ${list_available_test} ]]; then
    ls -1
    exit 0
fi

if [[ ! -d ${test_name} ]]; then
    echo "ERROR: incorrect test name"
    exit 1
fi

cd ${test_name}

if [[ ${gui} ]]; then
    runSVUnit -s questa -r '-gui -voptargs=+acc'
else
    runSVUnit -s questa
    [[ $(cat run.log | grep '\[testrunner\]' | tail -n 1) =~ "PASSED" ]]
fi
