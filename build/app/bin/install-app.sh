#!/bin/bash

# build arguments that are needed at runtime are saved here
mkdir -p /build

# DOWNLOAD_URL_EXAMPLE="https://audirvana.com/delivery/AudirvanaLinux.php?product=origin&arch=arm64&distrib=deb"

ARCH_KEY_AMD64=x86_64
ARCH_KEY_ARM64=aarch64
ARCH_VAL_AMD64=amd64
ARCH_VAL_ARM64=arm64

declare -A arch_postfix
arch_postfix[${ARCH_KEY_AMD64}]=${ARCH_VAL_AMD64}
arch_postfix[${ARCH_KEY_ARM64}]=${ARCH_VAL_ARM64}

if [[ -z "${BINARY_TYPE}" ]]; then
    echo "BINARY_TYPE not set!"
    exit 1
else
    echo "BINARY_TYPE=[${BINARY_TYPE}]"
fi

if [[ "${BINARY_TYPE}" != "origin" ]] && [[ "${BINARY_TYPE}" != "studio" ]]; then
    echo "Invalid BINARY_TYPE [${BINARY_TYPE}]!"
    exit 1
else
    echo "BINARY_TYPE [${BINARY_TYPE}] is valid."
fi

# Store binary type, needed when running
echo $BINARY_TYPE > "/build/binary-type"

arch=`uname -m`
echo "Current Architecture is [$arch]"
if [[ "${arch}" != "${ARCH_KEY_AMD64}" ]] && [[ "${arch}" != "${ARCH_KEY_ARM64}" ]]; then
    echo "Invalid architecture [${arch}]"
    exit 1
fi

binary_postfix=${arch_postfix[${arch}]}
echo "Binary postfix is [${binary_postfix}]"

DEB_FILE_URL="https://audirvana.com/delivery/AudirvanaLinux.php?product=${BINARY_TYPE}&arch=${binary_postfix}&distrib=deb"
echo "DEB_FILE_URL=[${DEB_FILE_URL}]"

wget -O /tmp/app.deb "${DEB_FILE_URL}"

# Installation
echo "Installing..."
dpkg -i "/tmp/app.deb"
echo "Installed."

rm /tmp/app.deb
