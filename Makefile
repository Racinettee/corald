LUADIR=`pwd`/dep/LuaJIT-2.0.4/src
LUA_INC=$(LUADIR)
LUA_LIBDIR=$(LUADIR)

all: gather deps corald

build:
	dub build --parallel
	mkdir -p bin
	cp ./corald ./bin

run:
	./bin/corald

buildrun: build run

deps:
	make -C dep/LuaJIT-2.0.4
	make -C dep/lgi CFLAGS="-Wall -Wextra -O2 -I$(LUADIR)"
	make -C dep/lpeg-1.0.0 LUADIR=$(LUADIR)
	make -C dep/luafilesystem LUA_INC=$(LUA_INC) LUA_LIBDIR=$(LUA_LIBDIR)
	mkdir -p dep/bin
	cp dep/lpeg-1.0.0/lpeg.so dep/bin
	cp dep/luafilesystem/src/lfs.so dep/bin
	mkdir -p dep/bin/lgi
	cp dep/lgi/lgi/corelgilua51.so dep/bin/lgi
	cp dep/lgi/lgi.lua script
	mkdir -p script/lgi
	cp dep/lgi/lgi/*.lua script/lgi
	cp -R dep/lgi/lgi/override script/lgi

gather:
	git submodule init
	git submodule update
	dub upgrade --missing-only
	echo "install library libgirepository1.0-dev with apt-get on ubuntu"

clean:
	make -C dep/LuaJIT-2.0.4 clean
	make -C dep/lgi clean
	make -C dep/lpeg-1.0.0 clean
	make -C dep/luafilesystem clean
	rm -f corald
