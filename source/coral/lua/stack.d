module coral.lua.stack;

import std.traits;
import std.string;
import core.memory;

import coral.lua.c.all;
import coral.lua.classes : pushLightUds;

/**
 * Get the associated Lua type for T.
 * Returns: Lua type for T
 */
template luaTypeOf(T)
{
	static if(is(T == enum))
		enum luaTypeOf = LUA_TSTRING;

	else static if(is(T == bool))
		enum luaTypeOf = LUA_TBOOLEAN;

	else static if(is(T == Nil))
		enum luaTypeOf = LUA_TNIL;

	else static if(is(T : const(char)[]) || is(T : const(char)*) || is(T == char) || isVoidArray!T)
		enum luaTypeOf = LUA_TSTRING;

	else static if(is(T : lua_Integer) || is(T : lua_Number))
		enum luaTypeOf = LUA_TNUMBER;

	else static if(isSomeFunction!T || is(T == LuaFunction))
		enum luaTypeOf = LUA_TFUNCTION;

	else static if(isArray!T || isAssociativeArray!T || is(T == LuaTable))
		enum luaTypeOf = LUA_TTABLE;

	else static if(is(T : const(Object)) || is(T == struct) || isPointer!T)
		enum luaTypeOf = LUA_TUSERDATA;

	else
		static assert(false, "No Lua type defined for `" ~ T.stringof ~ "`");
}

void pushInstance(T)(lua_State* L, T instance)
{
  T* ud = cast(T*)lua_newuserdata(L, (void*).sizeof);
  *ud = instance;
  GC.addRoot(ud);
  lua_newtable(L); // { }
  lua_getglobal(L, T.stringof); // { }, tmetatable
  lua_setfield(L, -2, "__index"); // { __index = tmetatable }
  pushLightUds!(T, 0)(L, *ud);
  lua_setmetatable(L, -2);
}

void pushValue(T)(lua_State* L, T value) if(!is(T == struct))
{
  static if(is(T == bool))
    lua_pushboolean(L, value);
  else static if(is(T == char))
    lua_pushlstring(L, &value, 1);
  else static if(is(T : lua_Integer))
    lua_pushinteger(L, value);
  else static if(is(T : lua_Number))
    lua_pushnumber(L, value);
  else static if(is(T : const(char)[]))
    lua_pushlstring(L, value.ptr, value.length);
  else static if(is(T : const(char)*))
    lua_pushstring(L, value);
  else static if(is(T == lua_CFunction) && functionLinkage!T == "C")
    lua_pushcfunction(L, value);
  else static if(is(T == class))
  {
    if(value is null)
      lua_pushnil(L);
    else
    {
			pushInstance(L, value);
		}
  }
  else
    static assert(false, "Unsupported type being pushed: "~T.stringof~" in stack.d");
}

void setGlobal(lua_State* L, string name)
{
	lua_setglobal(L, toStringz(name));
}