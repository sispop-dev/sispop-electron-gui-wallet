#!/bin/bash

# This script needs to run on an *actual* Mac with proper signing keys loaded.  It won't work in CI
# because Apple codesigning is unbelievably flakey.

rm -f bin/sispop*

./tools/download-sispop-files.sh https://download.sispop.site/sispop-io/sispop-core/sispop-stable-macos-LATEST.tar.xz

export NODE_OPTIONS=--openssl-legacy-provider

npm run build
