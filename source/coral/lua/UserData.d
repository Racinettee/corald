module coral.lua.UserData;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits;
import std.string : toStringz;

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

void pushInstance(T)(lua_State* state, T instance, luaL_Reg[] methodTable)
{
	T* t = cast(AppWindow*)lua_newuserdata(state, instance.sizeof);
	*t = instance;

	if(luaL_newmetatable(state, metatableName))
	{
		lua_pushvalue(state, -1);
		lua_setfield(state, -2, "__index");
		luaL_setfuncs(state, methodTable.ptr, 0);
		lua_setmetatable(state, -2);
	}

}