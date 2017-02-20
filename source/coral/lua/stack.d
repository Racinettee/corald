module coral.lua.stack;

import std.traits;

import coral.lua.c.all;
import coral.lua.priv.functions;

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

void pushValue(T)(lua_State* L, ref T value) if(is(T == struct))
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

/// Get a function argument from the stack.
auto getArgument(T, int narg)(lua_State* L, int idx)
{
	alias ParameterTypeTuple!T Args;

	static if(narg == -1) // varargs causes this
		alias ForeachType!(Args[$-1]) Arg;
	else
		alias Args[narg] Arg;

	enum isVarargs = variadicFunctionStyle!T == Variadic.typesafe;

	static if(isVarargs && narg == Args.length-1)
	{
		alias Args[narg] LastArg;
		alias ForeachType!LastArg ElemType;

		auto top = lua_gettop(L);
		auto size = top - idx + 1;
		LastArg result = new LastArg(size);
		foreach(i; 0 .. size)
		{
			result[i] = getArgument!(T, -1)(L, idx + i);
		}
		return result;
	}
	else static if(is(Arg == const(char)[]) || is(Arg == const(void)[]) ||
				   is(Arg == const(char[])) || is(Arg == const(void[])))
	{
		if(lua_type(L, idx) != LUA_TSTRING)
			argumentTypeMismatch(L, idx, LUA_TSTRING);

		size_t len;
		const(char)* cstr = lua_tolstring(L, idx, &len);
		return cstr[0 .. len];
	}
	else
	{
		// TODO: make an overload to handle struct and static array, and remove this Ref! hack?
		static if(isUserStruct!Arg) // user struct's need to return wrapped in a Ref
			return Ref!Arg(getValue!(Arg, argumentTypeMismatch)(L, idx));
		else
			return getValue!(Arg, argumentTypeMismatch)(L, idx);
	}
}