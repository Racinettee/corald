/++
Convenience module to import the Lua 5.1 C API.
This module also exposes luaL_tolstring which works like the function with the same name in Lua 5.2.
See_Also:
	Documentation for this API can be found $(LINK2 http://www.lua.org/manual/5.1/manual.html,here).
+/
module coral.lua.c.all;

public import coral.lua.c.lua, coral.lua.c.lauxlib, coral.lua.c.lualib, coral.lua.c.tostring;