module coral.lua.userdata;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits : fullyQualifiedName;
import std.string : toStringz, removechars;

/// Get a metatable name based on fullyQualifiedName of T - minus dots
pure immutable(string) metatableName(T)() @safe 
{
  return removechars(fullyQualifiedName!T, ".");
}
/// Get a metatable name based on fullyQualifiedName of T - minus dots
pure const(char)* metatableNamez(T)() @safe 
{
  return toStringz(metatableName!T);
}

/// Push an instance to lua, assuming that its class was registered
void pushInstance(T)(lua_State* state, T instance)
{
  T* t = cast(T*)lua_newuserdata(state, instance.sizeof);
  *t = instance;
  luaL_getmetatable(state, metatableNamez!T);
  lua_pushvalue(state, -1);
	lua_setmetatable(state, -3);
}

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

T* checkInstanceOf(T)(lua_State* state, int index) @trusted
{
  luaL_checktype(state, index, LUA_TUSERDATA);
  return cast(T*)luaL_checkudata(state, 1, metatableNamez!T);
}

/// Check and return that the value at the index is of T and return
T checkClassInstanceOf(T)(lua_State* state, int index) @safe
{
  return *checkInstanceOf!T(state, index);
}

void registerClass(T)(lua_State* L, const luaL_Reg[] static_methods, const luaL_Reg[] meta_methods)
{
  lua_CFunction register = (L) @trusted {
    // Create a new table, and apply functions to it
    lua_newtable(L);
    luaL_setfuncs(L, static_methods.ptr, 0);

    // Create a metatable, and apply meta functions to it
    if(luaL_newmetatable(L, metatableNamez!T))
    {
      luaL_setfuncs(L, meta_methods.ptr, 0);

      // Apply the metatable to the index field
      lua_pushliteral(L, "__index");
      lua_pushvalue(L, -3);               /* dup methods table*/
      lua_rawset(L, -3);                  /* metatable.__index = methods */
      lua_pushliteral(L, "__metatable");
      lua_pushvalue(L, -3);               /* dup methods table*/
      lua_rawset(L, -3);                  /* hide metatable:
                      metatable.__metatable = methods */
    }
    lua_pop(L, 1);                      /* drop metatable */
    return 1;                           /* return methods on the stack */
  };

  luaL_requiref(L, T.stringof, register, 0);
  lua_pop(L, 1);
}