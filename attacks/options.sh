#!/bin/bash

show_usage() {
cat << _EOF_
    Go get some life. Utility to perform recon workflow for a domain
    Usage:
            -h, --help              Show  help
            -b, --basic             Execute Basic workflow for Domain
            -f, --full              Execute Full workflow for Domain
_EOF_
}

while getopts ":b:f:" o; do
    case "${o}" in
        b)
            bash /tornado/attacks/basic.sh $2;
            ;;
        f)
            bash /tornado/attacks/full.sh $2;
            ;;
        *)
            show_usage; exit 1
            ;;
    esac
done

