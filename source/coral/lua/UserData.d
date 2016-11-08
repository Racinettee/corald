module coral.lua.UserData;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits;
import std.string : toStringz, removechars;

import coral.lua.Lua;

T toType(T)(lua_State* L, int index)
{
  T* obj = cast(T*)lua_touserdata(L, index);
  if(obj == null)
    luaL_typeerror(L, index, 
      toStringz(fullyQualifiedName!T));
  return obj;
}

T checkType(T)(lua_State* L, int index)
{
  luaL_checktype(L, index, Type.LightUserdata);
  T obj = cast(T)luaL_checkudata(L, index,
    toStringz(fullyQualifiedName!T));
  if(obj == null)
    luaL_typeerror(L, index,
      toStringz(fullyQualifiedName!T));
  return obj;
}

pure string metatableName(T)() @safe
{
  return removechars(fullyQualifiedName!T, ".");
}

pure const(char)* metatableNamez(T)() @safe 
{
  return toStringz(metatableName!T);
}

void pushInstance(T)(lua_State* state, T instance, const luaL_Reg[] methodTable)
{
	import std.traits : fullyQualifiedName;
	
	T* t = cast(T*)lua_newuserdata(state, instance.sizeof);
	*t = instance;

	if(luaL_newmetatable(state, toStringz(metatableName!T)))
	{
		lua_pushvalue(state, -1);
		lua_setfield(state, -2, "__index");
		luaL_setfuncs(state, methodTable.ptr, 0);
  }
  lua_setmetatable(state, -2);
}

T* checkInstanceOf(T)(lua_State* state, int index)
{
  return cast(T*)luaL_checkudata(state, 1, metatableNamez!T);
}

T checkClassInstanceOf(T)(lua_State* state, int index)
{
  return *checkInstanceOf!T;
}