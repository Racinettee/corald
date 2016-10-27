cd dep
cd lua && make PLAT=linux
cd -
cd lpeg-1.0.0 && make LUADIR=../lua/src
cd -
cd luafilesystem && make LUA_INC=../lua/src LUA_LIBDIR=../lua/src
cd -
cd lgi-0.9.1 && make CFLAGS="-Wall -Wextra -O2 -g -I../../lua/src"
cd -
mkdir -p bin
cd bin
cp ../lpeg-1.0.0/lpeg.so ./
cp ../luafilesystem/src/lfs.so ./
mkdir -p lgi
cp ../lgi-0.9.1/lgi/corelgilua51.so ./lgi
cd -
cd ../script
cp ../dep/lgi-0.9.1/lgi.lua ./
mkdir -p lgi
cp ../dep/lgi-0.9.1/lgi/*.lua ./lgi
cp -R ../dep/lgi-0.9.1/lgi/override ./lgi
cd -