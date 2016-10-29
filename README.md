# corald
Code editor in D using GtkD

### About
corald is meant to be light weight and plugin extensible. The plugin system uses lua and moonscript to achieve the light weight extensibility requirement.

### Bundle
The corald source code comes pre-bundled with lua, moonscript - as well as the required packages for moonscript, and lgi.

### To build
From the project root just run dub. Dub will run depbuild.sh as a pre build command which will get lua, moon script and lgi set up. If lgi fails to build
then `cd dep/lgi-0.9.1` and then `make CFLAGS="-Wall -Wextra -O2 -g -I../../lua/src"`... run dub again and if everything works then corald will start up.
