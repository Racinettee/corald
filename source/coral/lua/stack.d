module coral.lua.stack;

import std.traits;
import std.string;
import std.stdio;
import core.memory;

import coral.lua.exception;
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

private extern(C) int udIndexMetamethod(lua_State* L)
{
  lua_getmetatable(L, 1);
  lua_getfield(L, -1, luaL_checkstring(L, 2));
  if(cast(bool)lua_isnil(L, -1))
  {
    lua_pop(L, 1);
    lua_getfield(L, -1, "__class");
    lua_getfield(L, -1, luaL_checkstring(L, 2));
    lua_remove(L, -2);
  }
  return 1;
}

void pushInstance(T)(lua_State* L, T instance)
{
  T* ud = cast(T*)lua_newuserdata(L, (void*).sizeof); // ud
  *ud = instance;
  GC.addRoot(ud);
  lua_newtable(L); // ud, { }
  lua_pushcfunction(L, &udIndexMetamethod); // ud, { }, cindxmethod
  lua_setfield(L, -2, "__index"); // ud, { __index=cindxmethod }
  lua_getglobal(L, T.stringof); // ud, { __index=cindxmethod }, tmetatable
  if(cast(bool)lua_isnil(L, -1)) // Make sure that the metatable for the class exists
    luaL_error(L, toStringz("Error: class "~T.stringof~" has not been registered"));
  lua_setfield(L, -2, "__class"); // ud, { __index=cindxmethod, __class=tmetatable }
  pushLightUds!(T, 0)(L, *ud); // ud, { }, { __index=cindxmethod, __class=tmetatable, lightuds }
  lua_setmetatable(L, -2); // ud( ^ )
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
			pushInstance(L, value);
  }
  else
    static assert(false, "Unsupported type being pushed: "~T.stringof~" in stack.d");
}

@safe void setGlobal(lua_State* L, string name)
{
  if(!(L is null) && !(name is null))
	  (() @trusted => lua_setglobal(L, toStringz(name)))();
  else
    throw new StateException("Lua state or name for global were null");
}

import std.exception;
unittest
{
  assertThrown!StateException(setGlobal(null, "Example"), "setGlobal should have thrown because null passed to ptr");
  lua_State* L = luaL_newstate();
  assertThrown!StateException(setGlobal(L, null), "setGlobal should have thrown because passed name string was null");
  pushValue(L, null);
  assert(lua_isnil(L, -1));
  pushValue(L, true);
  assert(lua_type(L, -1) == LUA_TBOOLEAN);
  pushValue(L, 1);
  assert(lua_type(L, -1) == LUA_TINTEGER);
  pushValue(L, 1.0f);
  assert(lua_type(L, -1) == LUA_TNUMBER);
  pushValue(L, 1.0);
  assert(lua_type(L, -1) == LUA_TNUMBER);
  pushValue(L, "Hola");
  assert(lua_type(L, -1) == LUA_TSTRING);
  lua_CFunction holaFunction = (lua_State*) { };
  pushValue(L, holaFunction);
  assert(lua_type(L, -1) == LUA_TFUNCTION);
  lua_pop(L, 7);
  lua_close(L);
}