#!/usr/bin/env bash

# Script used with Drone CI to upload build artifacts (because specifying all this in
# .drone.jsonnet is too painful).



set -o errexit

if [ -z "$SSH_KEY" ]; then
    echo -e "\n\n\n\e[31;1mUnable to upload artifact: SSH_KEY not set\e[0m"
    # Just warn but don't fail, so that this doesn't trigger a build failure for untrusted builds
    exit 0
fi

echo "$SSH_KEY" >ssh_key

set -o xtrace  # Don't start tracing until *after* we write the ssh key

chmod 600 ssh_key

branch_or_tag=${DRONE_BRANCH:-${DRONE_TAG:-unknown}}

upload_to="oxen.rocks/${DRONE_REPO// /_}/${branch_or_tag// /_}"

MACOS_APP=${MACOS_APP:-"dist/electron/Packaged/mac/Oxen Electron Wallet.app"}
if [ "$(uname -s)" == "Darwin" ]; then
    if codesign -v "$MACOS_APP"; then
        echo -e "\e[32;1mApp is codesigned!"
    else
        echo -e "\e[33;1mApp is not codesigned; renaming to -unsigned"
        if [ -z "$MAC_BUILD_IS_CODESIGNED" ]; then
            for f in dist/electron/Packaged/{oxen-electron-wallet,latest}*-mac*; do
                if [[ $f = *\** ]]; then  # Unexpanded glob means it didn't match anything
                    echo "Did not find any files matching $f"
                fi
                newname="${f/mac/mac-unsigned}"
                mv "$f" "$newname"
                if [[ "$f" = *.yml ]]; then
                    sed -ie 's/-mac/-mac-unsigned/' "$newname"
                fi
            done
        fi
    fi
fi

puts=
for f in dist/electron/Packaged/{oxen-electron-wallet-*,latest*.yml}; do
    if [[ $f = *\** ]]; then  # Unexpanded glob means it didn't match anything
        echo "Did not find any files matching $f"
        ls --color -F -l dist/electron/Packaged
        exit 1
    fi
    puts="$puts
put $f $upload_to"
done

# sftp doesn't have any equivalent to mkdir -p, so we have to split the above up into a chain of
# -mkdir a/, -mkdir a/b/, -mkdir a/b/c/, ... commands.  The leading `-` allows the command to fail
# without error.
upload_dirs=(${upload_to//\// })
mkdirs=
dir_tmp=""
for p in "${upload_dirs[@]}"; do
    dir_tmp="$dir_tmp$p/"
    mkdirs="$mkdirs
-mkdir $dir_tmp"
done

sftp -i ssh_key -b - -o StrictHostKeyChecking=off drone@oxen.rocks <<SFTP
$mkdirs
$puts
SFTP

set +o xtrace

echo -e "\n\n\n\n\e[32;1mUploaded to https://${upload_to}/${filename}\e[0m\n\n\n"

