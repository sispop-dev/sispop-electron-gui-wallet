#!/bin/bash

# This script needs to run on an *actual* Mac with proper signing keys loaded.  It won't work in CI
# because Apple codesigning is unbelievably flakey.

rm -f bin/oxen*

./tools/download-oxen-files.sh https://oxen.rocks/oxen-io/oxen-core/oxen-stable-macos-LATEST.tar.xz

export NODE_OPTIONS=--openssl-legacy-provider

npm run build
