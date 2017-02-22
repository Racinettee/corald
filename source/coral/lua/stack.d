module coral.lua.stack;

import std.traits;

import coral.lua.c.all;
import coral.lua.priv.util;
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
private:
/**
 * Get a value of any type from the stack.
 * Params:
 *	 T = type of value
 *	 typeMismatchHandler = function called to produce an error in case of an invalid conversion.
 *	 L = stack to get from
 *	 idx = value stack index
 */
T getValue(T, alias typeMismatchHandler = defaultTypeMismatch)(lua_State* L, int idx) if(!isUserStruct!T)
{
	debug //ensure unchanged stack
	{
		int _top = lua_gettop(L);
		scope(success) assert(lua_gettop(L) == _top);
	}

	//ambiguous types
	static if(is(T == wchar) || is(T : const(wchar)[]) ||
			  is(T == dchar) || is(T : const(dchar)[]))
	{
		static assert("Ambiguous type " ~ T.stringof ~ " in stack push operation. Consider converting before pushing.");
	}

	static if(!is(T == LuaObject) && !is(T == LuaDynamic) && !isVariant!T)
	{
		int type = lua_type(L, idx);
		enum expectedType = luaTypeOf!T;

		//if a class reference, return null for nil values
		static if(is(T : const(Object)) || isPointer!T)
		{
			if(type == LuaType.Nil)
				return null;
		}

		if(type != expectedType)
			typeMismatchHandler(L, idx, expectedType);
	}

	static if(is(T == LuaFunction)) // WORKAROUND: bug #6036
	{
		LuaFunction func;
		func.object = LuaObject(L, idx);
		return func;
	}
	else static if(is(T == LuaDynamic)) // ditto
	{
		LuaDynamic obj;
		obj.object = LuaObject(L, idx);
		return obj;
	}
	else static if(is(T : LuaObject))
		return T(L, idx);

	else static if(is(T == Nil))
		return nil;

	else static if(is(T == enum))
		return getEnum!T(L, idx);

	else static if(is(T == bool))
		return lua_toboolean(L, idx);

	else static if(is(T == char))
		return *lua_tostring(L, idx); // TODO: better define this

	else static if(is(T : lua_Integer))
		return cast(T)lua_tointeger(L, idx);

	else static if(is(T : lua_Number))
		return cast(T)lua_tonumber(L, idx);

	else static if(is(T : const(char)[]) || isVoidArray!T)
	{
		size_t len;
		const(char)* str = lua_tolstring(L, idx, &len);
		static if(is(T == char[]) || is(T == void[]))
			return str[0 .. len].dup;
		else
			return str[0 .. len].idup;
	}
	else static if(is(T : const(char)*))
		return lua_tostring(L, idx);

	else static if(isAssociativeArray!T)
		return getAssocArray!T(L, idx);

	else static if(isArray!T)
		return getArray!T(L, idx);

	else static if(isVariant!T)
	{
		if(!isAllowedType!T(L, idx))
			luaL_error(L, "Type not allowed in Variant: %s", luaL_typename(L, idx));

		return getVariant!T(L, idx);
	}

	else static if(isSomeFunction!T)
		return getFunction!T(L, idx);

	else static if(isPointer!T)
		return getPointer!T(L, idx);

	else static if(is(T : const(Object)))
		return getClassInstance!T(L, idx);

	else
	{
		static assert(false, "Unsupported type `" ~ T.stringof ~ "` in stack read operation");
	}
}

// we need an overload that handles struct and static arrays (which need to return by ref)
ref T getValue(T, alias typeMismatchHandler = defaultTypeMismatch)(lua_State* L, int idx) if(isUserStruct!T)
{
	debug //ensure unchanged stack
	{
		int _top = lua_gettop(L);
		scope(success) assert(lua_gettop(L) == _top);
	}

	// TODO: confirm that we need this in this overload...?
	static if(!is(T == LuaObject) && !is(T == LuaDynamic) && !isVariant!T)
	{
		int type = lua_type(L, idx);
		enum expectedType = luaTypeOf!T;

		//if a class reference, return null for nil values
		static if(is(T : const(Object)))
		{
			if(type == LuaType.Nil)
				return null;
		}

		if(type != expectedType)
			typeMismatchHandler(L, idx, expectedType);
	}

	static if(isArray!T)
		return getArray!T(L, idx);

	else static if(is(T == struct))
		return getStruct!T(L, idx);

	else
	{
		static assert(false, "Shouldn't be here! `" ~ T.stringof ~ "` should be handled by the other overload.");
	}
}