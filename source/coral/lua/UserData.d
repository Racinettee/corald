module coral.lua.userdata;

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

//void pushInstance(T)(lua_State)

/// Push an instance of T with a group of methods on to the stack
/// The table for the user data is left on the stack
void pushInstance(T)(lua_State* state, T instance, const luaL_Reg[] methodTable)
{	
	T* t = cast(T*)lua_newuserdata(state, instance.sizeof);
	*t = instance;

	if(luaL_newmetatable(state, metatableNamez!T))
	{
		lua_pushvalue(state, -1);
    lua_pushvalue(state, -1); // extra copy of table on 
    // The user data is the self for method calls
		lua_setfield(state, -3, "__index"); // -2 in normal circumstance
		luaL_setfuncs(state, methodTable.ptr, 0);
  }
  lua_setmetatable(state, -3);
  lua_remove(state, -3);
  // A copy of the table is left on the estack
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