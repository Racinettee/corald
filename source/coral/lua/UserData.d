module coral.lua.UserData;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits : fullyQualifiedName;
import std.string : toStringz, removechars;

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
	T* t = cast(T*)lua_newuserdata(state, instance.sizeof);
	*t = instance;

	if(luaL_newmetatable(state, metatableNamez!T))
	{
		lua_pushvalue(state, -1);
		lua_setfield(state, -2, "__index");
		luaL_setfuncs(state, methodTable.ptr, 0);
  }
  lua_setmetatable(state, -2);
}

T* checkInstanceOf(T)(lua_State* state, int index)
{
  luaL_checktype(state, index, LUA_TUSERDATA);
  return cast(T*)luaL_checkudata(state, 1, metatableNamez!T);
}

T checkClassInstanceOf(T)(lua_State* state, int index)
{
  return *checkInstanceOf!T(state, index);
}