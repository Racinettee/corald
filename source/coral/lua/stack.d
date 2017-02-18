module coral.lua.stack;

import coral.lua.c.all;

void pushValue(T)(lua_State* L, T value) if(!isUserStruct!T)
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
    // Push function...
  { }
  else static if(isPointer!T)
    // Push pointer
  { }
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

void pushValue(T)(lua_State* L, ref T value) if(isUserStruct!T)
{
  static if(isArray!T)
  { }// push array
  else static if(is(T == struct))
  { }// push struct
  else
    static assert(false, "Unknown type being pushed: "~T.stringof~" in stack.d");
}

void pushFunction(T)(lua_State* L, T func) if(isSomeFunction!T)
{
  static if(isFunctionPointer!T)
    lua_pushlightuserdata(L, func);
  else
  {
    T* udata = cast(T*)lua_newuserdata(L, T.sizeof);
    *udata = func;

    GC.addRoot(udata);

    if(luaL_newmetatable(L, "__dcall") == 1)
    {
      lua_pushcfunction(L, &userdataCleaner);
      lua_setfield(L, -2, "__gc");
    }
    lua_setmetatable(L, -2);
  }
  lua_pushcclosure(L, &functionWrapper!T, 1);
}