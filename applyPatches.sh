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

applyPatches() {
    from=$1
    to=$2

    git clone "$1" "$2"
    pushd "$2"
    git remote add upstream "../$from"
    git fetch upstream
    git reset --hard upstream/master
    git am --abort > /dev/null 2>&1
    git am --3way --no-gpg-sign --ignore-whitespace "$basedir/${from}-patches/"*.patch
    patchresult=$?
    popd

    if [ "$patchresult" == "0" ]; then
        echo "Patches applied cleanly to $to!"
    else
        echo "Patches did not apply cleanly to $to. Please fix."
        return 1
    fi
}

applyPatches launcher olauncher || exit 1
