#!/bin/bash
# OLauncher - A modified version of the old Minecraft Launcher
# Copyright (C) 2025 RagedMeteor1837
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.


basedir=$(pwd)
workdir=$basedir/work
extractdir=$workdir/extract
decompdir=$workdir/decomp

launcher_jar_url="https://launcher.mojang.com/v1/objects/eabbff5ff8e21250e33670924a0c5e38f47c840b/launcher.jar"
bootstrap_jar_url="https://web.archive.org/web/20221007091726if_/https://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar"

checkLocalFile() {
    local_file=$1
    download_url=$2
    file_desc=$3

    if [ ! -e "$workdir/$1" ]; then
    echo "Downloading $3..."
    mkdir -p work
    if ! curl -o "work/$1" "$2" > /dev/null; then
        echo "Failed to download $3!"
        exit 1
    fi
fi
}

class_extract() {
    source_file=$1
    target_dir=$2
    file_desc=$3
    echo "Extracting classes for $3..."
    mkdir -pv "$extractdir/$target_dir"
    pushd "$extractdir/$target_dir"
    if ! jar xf ../../$source_file; then
        echo "Failed to extract jar for $3"
        exit 1
    fi
    popd
}

decompile_component() {
    component=$1
    mkdir -pv "$decompdir/$component"
    if ! java -jar tools/fernflower.jar -dgs=1 -hdc=0 -asc=1 -udv=0 -ind="    " "$extractdir/$component" "$decompdir/$component"; then
        echo "Failed to decompile classes"
        exit 1
    fi
}

checkLocalFile "launcher.jar" "$launcher_jar_url" "vanilla launcher"
checkLocalFile "bootstrap.jar" "$bootstrap_jar_url" "vanilla launcher bootstrap"


if [ ! -e "$extractdir" ]; then
    class_extract launcher.jar launcher "vanilla launcher"
    class_extract bootstrap.jar bootstrap "vanilla launcher bootstrap"
    
    pushd "$extractdir"


    pushd "launcher"
    echo "Pruning classes for the launcher..."
    rm -rf org joptsimple javax com/google
    popd

    pushd "bootstrap"
    echo "Pruning classes for the bootstrap..."
    rm -rf joptsimple LZMA com/google
    popd

    popd
fi

if [ ! -e "$decompdir" ]; then
    echo "Decompiling..."
    decompile_component launcher
    decompile_component bootstrap
fi
