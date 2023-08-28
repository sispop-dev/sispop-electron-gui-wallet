#!/bin/bash

if [ "$#" -ne 1 ] || [[ "$1" != http* ]]; then
    cat <<EOF >&2
Usage: $0 URL -- download and extract an sispop-core build (typically from https://download.sispop.site)
Some common URLs:
    https://download.sispop.site/sispop-io/sispop-core/sispop-stable-linux-LATEST.tar.xz
    https://download.sispop.site/sispop-io/sispop-core/sispop-stable-win-LATEST.zip
    https://download.sispop.site/sispop-io/sispop-core/sispop-stable-macos-LATEST.tar.xz
    https://download.sispop.site/sispop-io/sispop-core/sispop-dev-linux-LATEST.tar.xz
    https://download.sispop.site/sispop-io/sispop-core/sispop-dev-win-LATEST.zip
    https://download.sispop.site/sispop-io/sispop-core/sispop-dev-macos-LATEST.tar.xz
EOF
    exit 1
fi

if ! [ -f tools/download-sispop-files.sh ] || ! [ -d bin ]; then
    echo "This script needs to be invoked from the sispop-electron-gui-wallet top-level project directory" >&2
    exit 1
fi

tar=tar
if [[ "$($tar --version)" == bsdtar* ]]; then
    tar=gtar
    if ! command -v $tar; then
        echo "GNU tar is required, but your tar is \`bsdtar' and \`gtar' doesn't work." >&2
        echo "This is probably a mac; please install gnutar (e.g. via macports or homebrew)" >&2
        exit 1
    fi
fi

rm -f bin/sispop*

if [[ "$1" = *win*.zip ]]; then
    tmpzip=$(mktemp XXXXXXXXXXXX.zip)
    curl -sSo $tmpzip "$1"
    unzip -p $tmpzip '*/sispopd.exe' >bin/sispopd.exe
    unzip -p $tmpzip '*/sispop-wallet-rpc.exe' >bin/sispop-wallet-rpc.exe
    rm -f $tmpzip

    echo "Extracted:"
    ls -l bin/*.exe
else
    curl -sS "$1" | $tar --strip-components=1 -C bin -xJv --no-anchored sispopd sispop-wallet-rpc

    echo "Checking downloaded versions:"
    echo -n "sispopd: "; ./bin/sispopd --version
    echo -n "sispop-wallet-rpc: "; ./bin/sispop-wallet-rpc --version
fi
