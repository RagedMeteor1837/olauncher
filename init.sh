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
decompdir=$workdir/decomp

vanilla_launcher_dir=$basedir/launcher
vanilla_bootstrap_dir=$basedir/bootstrap

init_component() {
    decomp_comp_name=$1
    target_path=$2
    mkdir -p "$target_path"
    pushd "$target_path"
    git init
    cp -rv "$decompdir/$decomp_comp_name"/* .
    git add --all
    git commit --no-gpg-sign -m "Initial commit"
    popd
    echo "Component $decomp_comp_name initialized!"
}

if [ ! -e "$vanilladir" ]; then
    echo "Copying vanilla sources..."

    init_component "launcher" $vanilla_launcher_dir
    init_component "bootstrap" $vanilla_bootstrap_dir

fi
