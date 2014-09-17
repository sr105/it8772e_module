#!/bin/bash

[ "$1" == "-x" ] && set -x && shift

# Finds a path to a kernel directory that can be used to build
# a module outside of the kernel tree. This is based on the
# current version for a passed in linux-image metapackage.
get_kdir() {
    # Example input:
    local metapackage="linux-image-generic-lts-trusty"

    # Get the linux version from the passed metapackage
    [ "$1" == "" ] || metapackage="$1"
    local output=$(apt-cache policy $metapackage 2>&1)
    local version=$(echo "$output" |\
	sed -nE '/Candidate:/ s,[^[:digit:]]*([[:digit:]\.]+)\.([[:digit:]]+)\.[[:digit:]]+,\1-\2,p')
    if ! echo $version | grep -qE '^([0-9]+\.){2}[0-9]+-[0-9]+$'; then
	echo "version=$version"
	# Run it again because apt-cache does something weird
	# that prevents stderr redirection
	apt-cache policy $metapackage
	exit 1
    fi

    local dir=/usr/src/linux-headers-${version}-generic
    # Are the correct headers already installed on this system?
    [ -d $dir ] && KDIR=$dir && return 0

    local temp_dir=/tmp/RDM/linux_headers
    dir=$temp_dir$dir
    # Are the correct headers already installed in our temp directory?
    [ -d $dir ] && KDIR=$dir && return 0

    # Grab the headers and install them in the temp directory
    mkdir -p $temp_dir
    pushd $temp_dir >/dev/null

    local header_packages="linux-headers-${version}-generic linux-headers-${version}"
    echo "apt-get download --quiet --yes $header_packages"
    output=$(apt-get download --quiet --yes $header_packages 2>&1)
    echo "$output"
    echo "debs retrieved: "$(echo "$output" | awk '/^Get/ { print $4 }')
    for deb in linux-headers-${version}*.deb ; do
	echo "Unpacking $deb..."
	dpkg -x $deb .
    done

    popd >/dev/null

    # Are the correct headers already installed in our temp directory?
    [ -d $dir ] && KDIR=$dir && return 0

    echo "Failed to download linux-headers-${version}"
    exit 1
}

get_kdir "$1"
echo "KDIR=$KDIR"

export KDIR
make modules
