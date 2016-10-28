module coral.lua.UserData;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits;
import std.string : toStringz;

import coral.lua.Lua;

T toType(T)(lua_State* L, int index)
{
  T obj = cast(T)lua_touserdata(L, index);
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

void pushClassInstance(T)(lua_State* L, T obj) if (is(T == class))
{
	T* ud = cast(T*)lua_newuserdata(L, obj.sizeof);
	*ud = obj;

	pushMeta(L, obj);
	lua_setmetatable(L, -2);

	GC.addRoot(ud);
}

private void pushMeta(T)(lua_State* L, T obj)
{
	if(luaL_newmetatable(L, T.mangleof.ptr) == 0)
		return;

	pushValue(L, T.stringof);
	lua_setfield(L, -2, "__dclass");

	pushValue(L, T.mangleof);
	lua_setfield(L, -2, "__dmangle");

	lua_newtable(L); //__index fallback table

	foreach(member; __traits(derivedMembers, T))
	{
		static if(__traits(getProtection, __traits(getMember, T, member)) == "public" && //ignore non-public fields
			member != "this" && member != "__ctor" && //do not handle
			member != "Monitor" && member != "toHash" && //do not handle
			member != "toString" && member != "opEquals" && //handle below
			member != "opCmp") //handle below
		{
			static if(__traits(getOverloads, T.init, member).length > 0 && !__traits(isStaticFunction, mixin("T." ~ member)))
			{
				pushMethod!(T, member)(L);
				lua_setfield(L, -2, toStringz(member));
			}
		}
	}

	lua_setfield(L, -2, "__index");

	pushMethod!(T, "toString")(L);
	lua_setfield(L, -2, "__tostring");

	pushMethod!(T, "opEquals")(L);
	lua_setfield(L, -2, "__eq");

	//TODO: handle opCmp here


	lua_pushcfunction(L, &classCleaner);
	lua_setfield(L, -2, "__gc");

	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__metatable");
}