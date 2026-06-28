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
autooldir=$basedir/AutoOL
workdir=$basedir/work

OLAUNCHER_VERSION=2.3.1
AUTOOL_VERSION=0.1.1
BOOTSTRAP_VERSION=1.6.0

finalname="olauncher-$OLAUNCHER_VERSION-redist.jar"

if [ ! -e "$autooldir" ]; then
  echo "The AutoOL directory could not be found. Please run 'git submodule update --init'"
  exit 1
fi

if [ ! -e "$workdir/redist" ]; then
  mkdir -pv "$workdir/redist"
fi

cd "$workdir/redist"

echo "Building AutoOL..."
pushd "$autooldir"
mvn clean package
mvnresult="$?"
popd

if [ "$mvnresult" != "0" ]; then
  echo "Error building AutoOL"
  exit 1
fi

echo "Generating launcher patch..."
if ! java -jar "jbsdiff/target/jbsdiff-1.0.jar" diff "../launcher.jar" "$basedir/olauncher/target/olauncher-${OLAUNCHER_VERSION}.jar" "launcher.bsdiff" || [ ! -e "launcher.bsdiff" ]; then
  echo "Error creating patch"
  exit 1
fi

echo "Generating bootstrap patch..."
if ! java -jar "jbsdiff/target/jbsdiff-1.0.jar" diff "../bootstrap.jar" "$basedir/bootstrap-olauncher/target/bootstrap-olauncher-${BOOTSTRAP_VERSION}.jar" "bootstrap.bsdiff" || [ ! -e "bootstrap.bsdiff" ]; then
  echo "Error creating patch"
  exit 1
fi

echo "Generating properties..."
(
cat - << EOP
origurl=https://web.archive.org/web/20221007091726if_/https://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar
orighash=$(sha1sum "../bootstrap.jar" | cut -d ' ' -f 1)
origname=Minecraft.jar
origsz=$(du -b "../bootstrap.jar" | cut -f 1)
patchres=/bootstrap.bsdiff
patchsz=$(du -b "bootstrap.bsdiff" | cut -f 1)
finalhash=$(sha1sum "$basedir/bootstrap-olauncher/target/bootstrap-olauncher-${BOOTSTRAP_VERSION}.jar" | cut -d ' ' -f 1)
finalname=patched.jar
finalsz=$(du -b "$basedir/bootstrap-olauncher/target/bootstrap-olauncher-${BOOTSTRAP_VERSION}.jar" | cut -f 1)
interactive=true
buildtimestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
#mainClass=
EOP
) > "patch.properties"

echo "Inserting patch and properties into jar..."
cp "$autooldir/target/AutoOL-${AUTOOL_VERSION}.jar" "$finalname"
jar -uf "$finalname" "bootstrap.bsdiff" "patch.properties"
jarres="$?"

if [ "$jarres" != "0" ]; then
  echo "jar returned nonzero exit status $jarres"
  exit 1
fi

mv "$finalname" "$basedir/$finalname"
mv "launcher.bsdiff" "$basedir/launcher.bsdiff"
echo "Redistributable created with name $finalname"
