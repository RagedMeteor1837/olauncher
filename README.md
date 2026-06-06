# olauncher
The old launcher we all know and love with the QoL features of the new launcher.

## Project Status
This project is maintained on a best-effort basis and updates will only be made when I have the time. See [here](https://ragedmeteor1837.github.io/olauncherabout/news/) for more information.

## How to use
1. Go to the [latest release](https://github.com/RagedMeteor1837/olauncher/releases/latest)
2. Download the `olauncher-xxx-redist.jar` file
3. Run it

## Features
- Microsoft authentication
- Bundled JVMs
  - Automatically downloads the appropriate JVM for all minecraft versions
  - You just need a runtime to open the actual launcher
  - You can still provide your own JVMs
- Update checking
- Displays latest release notes
- ~~Displays Mojang server status~~
- Custom launch arguments

## Build from source
**1. Clone the repository**
   ```bash
   git clone https://github.com/RagedMeteor1837/olauncher.git
   cd olauncher
   git submodule update --init
  ```
**2. Run the build scripts<br>**
These commands must be run in the following order to build from source:
- `decompile.sh`
  - Downloads the original launcher JAR and decompiles it into source files.
- `init.sh`
  - Initialises the decompiled sources as a new Git repository.
- `applyPatches.sh`
  - Applies OLauncher patches to the decompiled sources
- `mvn clean package`
  - Builds and packages the patched launcher using Maven.
- `genredist.sh` (optional)
  - Generates the redistributable JAR - Do not distribute the JARs in `olauncher/target`!

## Other scripts
- `clean.sh`
  - Cleans the source directory
- `maintain.sh`
  - Provides maintenance utilities for the launcher build.
- `rebuildPatches.sh`
  - Regenerates patch files by cleaning and updating them against the current repository state.