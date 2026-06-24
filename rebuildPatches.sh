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

cleanupPatches() {
  pushd "$1"
  for patch in *.patch; do
    gitver=$(tail -n 2 "$patch" | grep -ve "^$" | tail -n 1)
    diffs=$(git diff --staged "$patch" | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index)")

    testver=$(echo "$diffs" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "$gitver")
    if [ "x$testver" != "x" ]; then
        diffs=$(echo "$diffs" | sed 'N;$!P;$!D;$d')
    fi

    if [ "x$diffs" == "x" ] ; then
        git reset HEAD "$patch" >/dev/null
        git checkout -- "$patch" >/dev/null
    fi
  done
  popd
}

rebuildPatches() {
    from=$1
    to=$2

    mkdir -p "${from}-patches"
    pushd "$to"
    git format-patch --no-stat -N -o "$basedir/${from}-patches" origin/HEAD
    popd

    git add "${from}-patches"/*.patch
    cleanupPatches "${from}-patches"
}

if [ "$1" = "launcher" ] || [ -z "$1" ]; then
    rebuildPatches launcher olauncher
elif [ "$1" = "bootstrap" ]; then
    rebuildPatches bootstrap bootstrap-olauncher
elif [ "$1" = "all" ]; then
    rebuildPatches launcher olauncher
    rebuildPatches bootstrap bootstrap-olauncher
else
  echo "Target '$1' for rebuilding patches not found. Accepted targets are:"
  echo "   launcher"
  echo "   bootstrap"
  echo "   all"
  echo "If not specified, the default target is launcher"
  exit 1
fi
