module coral.lua.classes;

import core.memory;
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

void fillArgs(Del, int index)(lua_State* L, ref Parameters!Del params)
{
  static if(is(params[index] == int))
  {

  }
}

extern(C) int methodWrapper(Del, Class)(lua_State* L)
{
  alias ParameterTypeTuple!Del Args;

  static assert ((variadicFunctionStyle!Del != Variadic.d && variadicFunctionStyle!Del != Variadic.c),
		"Non-typesafe variadic functions are not supported.");

  int top = lua_gettop(L);

  static if (variadicFunctionStyle!Del == Variadic.typesafe)
		enum requiredArgs = Args.length;
	else
		enum requiredArgs = Args.length + 1;

  if(top < requiredArgs)
  {
    writeln("Argument error in D method wrapper");
    return 0;
  }
  
  Class self = *cast(Class*)lua_touserdata(L, 1);
  
  Del func;
  func.ptr = cast(void*)self;
  func.funcptr = cast(typeof(func.funcptr))lua_touserdata(L, lua_upvalueindex(1));

  Parameters!Del typeObj;
  pragma(msg, typeObj);
  fillArgs!(Del, 0)(L, typeObj);

  //writeln("Nifty open file function : )");
  string fp = cast(string)fromStringz(luaL_checkstring(L, 2));
  typeObj[0] = fp;


  func(typeObj);

  //foreach(i, Arg; Args)
  //  args[i] = getArgument!(Del, i)(L, i + 2);
  // arity - returns number of arguments of function

  return 0;
}

extern(C) int newUserdata(T)(lua_State* L)
{
  T* ud = cast(T*)lua_newuserdata(L, (void*).sizeof);
  *ud = new T();
  GC.addRoot(ud);
  lua_newtable(L); // { }
  lua_getglobal(L, T.stringof); // { }, tmetatable
  lua_setfield(L, -2, "__index"); // { __index = tmetatable }
  pushLightUds!(T, 0)(L, *ud);
  lua_setmetatable(L, -2);
  return 1;
}

void registerClass(T)(State state)
{
  static assert(hasUDA!(T, LuaExport));

  lua_CFunction x_gc = (lua_State* L)
  {
    GC.removeRoot(lua_touserdata(L, 1));
    return 0;
  };

  lua_State* L = state.state;

  // -------------------------------------------------------------------
  // the top of the stack being the right-most in the following comments
  // -----------------------------------------------------
  // Create a metatable named after the D-class and add some constructors and methods
  // ---------------------------------------------------------------------------------
  pragma(msg, T.stringof~" IS THE CLSS");
  luaL_newmetatable(L, T.stringof); // x = {}
  lua_pushvalue(L, -1); // x = {}, x = {} 
  lua_setfield(L, -1, "__index"); // x = {__index = x}
  lua_pushcfunction(L, &newUserdata!(T)); // x = {__index = x}, x_new
  lua_setfield(L, -2, "new"); // x = {__index = x, new = x_new}
  lua_pushcfunction(L, x_gc); // x = {__index = x, new = x_new}, x_gc
  lua_setfield(L, -2, "__gc"); // x = {__index = x, new = x_new, __gc = x_gc}

  lua_CFunction sof = (lua_State* L)
  {
    //writeln("D STRINGOF");
    lua_pushstring(L, "D STRING HUEHUE");
    return 1;
  };
  lua_pushcfunction(L, sof);
  lua_setfield(L, -2, "__tostring");
  // ---------------------------------
  pushMethods!(T, 0)(L);
  lua_setglobal(L, T.stringof);
}

void pushMethods(T, uint index)(lua_State* L)
{
  pragma(msg, index);

  static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" &&
    hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport)) 
  {
    // Get the lua uda struct associated with this member function
    enum luaUda = getUDAs!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport)[0];
    pragma(msg, luaUda.name);
    static if(luaUda.type == "method")
    {
      alias DelType = typeof(mixin("&T.init."~__traits(derivedMembers, T)[index]));
      lua_pushlightuserdata(L, &mixin("T."~__traits(derivedMembers,T)[index])); // x = { ... }, &T.member
      lua_pushcclosure(L, &methodWrapper!(DelType, T), 1); // x = { ... }, closure { &T.member }
      lua_setfield(L, -2, toStringz(luaUda.name)); // x = { ..., fn = closure { &T.member } }
    }
  }
  static if(index+1 < __traits(derivedMembers, T).length)
    pushMethods!(T, index+1)(L);
}

// T refers to a de-referenced instance
void pushLightUds(T, uint index)(lua_State* L, T instance)
{
  pragma(msg, index);

  static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" &&
    hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport))
  {
    // Get the lua uda struct associated with this member function
    enum luaUda = getUDAs!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport)[0];
    pragma(msg, luaUda.name);
    static if(luaUda.type == "lightud")
    {
      static if(luaUda.submember != "")
        lua_pushlightuserdata(L, mixin("instance."~__traits(derivedMembers, T)[index]~"."~luaUda.submember));
      else
        lua_pushlightuserdata(L, &mixin("instance."~__traits(derivedMembers, T)[index]));
      lua_setfield(L, -2, toStringz(luaUda.name));
    }
  }
  static if(index+1 < __traits(derivedMembers, T).length)
    pushLightUds!(T, index+1)(L, instance);
}