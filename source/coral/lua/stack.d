module coral.lua.stack;

import std.traits;

import coral.lua.c.all;

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
  else static if(isSomeFunction!T)
    pushFunction(L, value);
  else static if(isPointer!T)
	{
    if(value is null)
			lua_pushnil(L);
		else
			pushPointer(L, value);
	}
  else static if(is(T == class))
  {
    if(value is null)
      lua_pushnil(L);
    else
      // push class instance
    { }
  }
  else
    static assert(false, "Unsupported type being pushed: "~T.stringof~" in stack.d");
}