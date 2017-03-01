module coral.lua.classes;

import std.stdio;
import std.string;
import std.traits;

import coral.lua.c.all;
import coral.lua.state;
import coral.lua.attrib;
import coral.lua.stack;

template hasCtor(T)
{
    enum hasCtor = __traits(compiles, __traits(getOverloads, T.init, "__ctor"));
}

// For use as __call
void pushCallMetaConstructor(T)(lua_State* L)
{
  static if(!hasCtor!T)
  {
    static T ctor(LuaObject self)
    {
      static if(is(T == class))
        return new T;
      else
        return T.init;
    }
  }
  else
  {
    // TODO: handle each constructor overload in a loop.
    //   TODO: handle each combination of default args
    alias Ctors = typeof(__traits(getOverloads, T.init, "__ctor"));
    alias Args = ParameterTypeTuple!(Ctors[0]);

    static T ctor(void* self, Args args)
    {
      static if(is(T == class))
        return new T(args);
      else
        return T(args);
    }
  }

  pushFunction(L, &ctor);
  lua_setfield(L, -2, "__call");
}

void registerClass(T)(State state)
{
  static assert(hasUDA!(T, LuaExport));

  lua_CFunction x_new = (lua_State* L)
  {
    T* ud = cast(T*)lua_newuserdata(L, __traits(classInstanceSize, T));
    *ud = new T();
    lua_getglobal(L, T.stringof);
    lua_setmetatable(L, -2);
    return 1;
  };

  lua_State* L = state.state;

  // -------------------------------
  lua_newtable(L); // x : {}
  lua_pushvalue(L, -1); // x : {}, x : {} 
  lua_setfield(L, -1, "__index"); // x : {__index = x}
  lua_pushcfunction(L, x_new); // x : {__index = x}, x_new
  lua_setfield(L, -2, "new"); // x : {__index = x, new = x_new}
  
  // ---------------------------------
  pushUDAMembers!(T, 0)(L);

  writeln("Registering methods");
  //foreach(method; methods)
  //{
  //    writeln(fromStringz(method.name));
  //}
}

void pushMethods(T, uint index)(lua_State* L)
{
  static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" &&
    hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport)) 
  {
    lua_pushcclosure
    getUDAs!(T, LuaExport)[0].name;
  }
}

void pushUDAMembers(T, uint index)(lua_State* L)
{
  static if(
    __traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" &&
    hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport))
  {
    pragma(msg, "Found a member with uda "~__traits(derivedMembers, T)[index]);
    //methods ~= luaL_Reg(cast(char*)toStringz(__traits(derivedMembers, T)[index]), cast(lua_CFunction)mixin("&T."~__traits(derivedMembers, T)[index]));
    pushFunction(__traits(derivedMembers,T)[index]);
  }
  
  static if(index + 1 < __traits(derivedMembers, T).length)
    pushUDAMembers!(T, index+1)(L);
}