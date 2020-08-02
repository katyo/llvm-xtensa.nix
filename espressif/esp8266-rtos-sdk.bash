#!/bin/bash

PKGDIR=$(dirname $(dirname $0))

print_help() {
    echo "Usage:"
    echo "  h|help              Prints this help"
    echo "  c|conf              Prints configuration"
    echo "  s|shell             Starts shell instantly"
    echo "  i|init [file.nix]   Creates nix-shell config (default.nix by default)"
}

if (($# < 1)); then
    print_help
    exit 0
fi

case "$1" in
    h|help)
        print_help
        exit 0
        ;;
    c|conf)
        echo "IDF_PATH=${PKGDIR}"
        exit 0
        ;;
    s|shell)
        nix-shell "${PKGDIR}/share/shell.nix"
        exit 0
        ;;
    i|init)
        dest_file="default.nix"
        if [ -n "$2" ]; then
            dest_file="$2"
        fi
        if [ -f "${dest_file}" ]; then
            echo "File ${dest_file} already exists!"
            exit 1
        fi
        cp "${PKGDIR}/share/shell.nix" "${dest_file}"
        chmod 644 "${dest_file}"
        if [ "${dest_file}" = "default.nix" ]; then
            shell_args=""
        else
            shell_args=" ${dest_file}"
        fi
        echo "File ${dest_file} created. You can start shell with command:"
        echo "$ nix-shell ${shell_args}"
        exit 0
        ;;
    *)
        echo "Unrecognized command: $1"
        print_help
        exit 1
esac
