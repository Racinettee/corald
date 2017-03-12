LUADIR=`pwd`/dep/LuaJIT-2.0.4/src
LUA_INC=$(LUADIR)
LUA_LIBDIR=$(LUADIR)

deps:
	make -C dep/LuaJIT-2.0.4
	make -C dep/lgi-0.9.1 CFLAGS="-Wall -Wextra -O2 -I$(LUADIR)"
	make -C dep/lpeg-1.0.0 LUADIR=$(LUADIR)
	make -C dep/luafilesystem LUA_INC=$(LUA_INC) LUA_LIBDIR=$(LUA_LIBDIR)
	mkdir -p dep/bin
	cp dep/lpeg-1.0.0/lpeg.so dep/bin
	cp dep/luafilesystem/src/lfs.so dep/bin
	mkdir -p dep/bin/lgi
	cp dep/lgi-0.9.1/lgi/corelgilua51.so dep/bin/lgi
	cp dep/lgi-0.9.1/lgi.lua script
	mkdir -p script/lgi
	cp dep/lgi-0.9.1/lgi/*.lua script/lgi
	cp -R dep/lgi-0.9.1/lgi/override script/lgi

clean:
	make -C dep/LuaJIT-2.0.4 clean
	make -C dep/lgi-0.9.1 clean
	make -C dep/lpeg-1.0.0 clean
	make -C dep/luafilesystem clean