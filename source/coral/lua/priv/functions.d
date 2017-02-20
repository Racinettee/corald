module coral.lua.priv.functions;

import core.memory;
import std.traits;
import std.typetuple;

import coral.lua.c.all;
import coral.lua.priv.util;

private:
void argsError(lua_State* L, int nargs, ptrdiff_t expected)
{
	lua_Debug debugInfo;
	lua_getstack(L, 0, &debugInfo);
	lua_getinfo(L, "n", &debugInfo);
	luaL_error(L, "call to %s '%s': got %d arguments, expected %d",
		debugInfo.namewhat, debugInfo.name, nargs, expected);
}
template StripHeadQual(T : const(T*)){alias StripHeadQual = const(T)*;}
template StripHeadQual(T : const(T[])){alias StripHeadQual = const(T)[];}
template StripHeadQual(T : immutable(T*)){alias StripHeadQual = immutable(T)*;}
template StripHeadQual(T : immutable(T[])){alias StripHeadQual = immutable(T)[];}
template StripHeadQual(T : T[]){alias StripHeadQual = T[];}
template StripHeadQual(T : T*){alias StripHeadQual = T*;}
template StripHeadQual(T : T[N], size_t N){alias StripHeadQual = T[N];}
template StripHeadQual(T){alias StripHeadQual = T;}
template FillableParameterTypeTuple(T)
{
	alias FillableParameterTypeTuple = staticMap!(StripHeadQual, ParameterTypeTuple!T);
}
template BindableReturnType(T)
{
  alias BindableReturnType = StripHeadQual!(ReturnType!T);
}
template TreatArgs(T...)
{
	static if(T.length == 0)
		alias TreatArgs = TypeTuple!();
	else static if(isUserStruct!(T[0])) // TODO: we might do this for static arrays too in future...?
		// we need to convert struct's into Ref's because 'ref' isn't part of the type in D, and it gets lots in the function calling logic
		alias TreatArgs = TypeTuple!(Ref!(T[0]), TreatArgs!(T[1..$]));
	else static if(is(T[0] == class))
		alias TreatArgs = TypeTuple!(Rebindable!(T[0]), TreatArgs!(T[1..$]));
	else
		alias TreatArgs = TypeTuple!(T[0], TreatArgs!(T[1..$]));
}
// Call with or without return value, propogating exceptions as lua errors.
// This should be throwing a userdata with __tostring and a reference to the
// thrown exception, as of now everything but the error type and message is lost
int callFunction(T, RT = BindableReturnType!T)(lua_State* L, T func, ParameterTypeTuble!T args)
if((returnsRef!T && isUserStruct!RT) || (!is(RT == const) && !is(RT == immutable)))
{
  try
  {
    static if(!is(RT == void))
    {
      // Should we support references for all types?
      static if(returnsRef!T && isUserStruct!RT)
        auto ret = Ref!RT(func(args));
      else static if(is(RT == inout(U), U))
        // Note: args[0] might not be the inout arg! We may have to search ParameterTypeTuple!T for inout args :/
        InOutReturnType!(func, typeof(args[0])) ret = func(args);
      else
        RT ret = func(args);
      return pushReturnValues(L, ret);
    }
    else
      func(args);
  }
  catch(Exception e)
  {
    luaL_error(L, "%s", toStringz(e.toString()));
  }
  return 0;
}
// Ditto, but wrap the try-catch in a nested function because the return value's
// declaration and initialization cannot be separated.
int callFunction(T, RT=BindableReturnType!T)(lua_State* L, T func, ParameterTypeTuble!T args)
if((!returnsRef!T || !isUserStruct!RT) && (is(RT==const) || is(RT==immutable)))
{
  auto ref call()
  {
    try
      return func(args);
    catch(Exception e)
      luaL_error(L, "%s", e.toString().toStringz());
  }
  return pushReturnValues(L, call());
}
package:
extern(C) int functionWrapper(T)(lua_State* L)
{
  alias Args = FillableParameterTypeTuple!T;

  static assert((variadicFunctionStyle!T != Variadic.d && variadicFunctionStyle!T != Variadic.c),
    "Non-typesafe variadic functions are not supported.");

  // Check arguments
  int top = lua_gettop(L);

  static if(variadicFunctionStyle!T == Variadic.typesafe)
    enum requiredArgs = Args.length - 1;
  else
    enum requiredArgs = Args.length;

  if(top < requiredArgs)
    argsError(L, top, requiredArgs);

  // Get function
  static if(isFunctionPointer!T)
    T func = cast(T)lua_touserdata(L, lua_upvalueindex(1));
  else
    T func = *cast(T*)lua_touserdata(L, lua_upvalueindex(1));

  // Assemble arguments
  TreatArgs!Args args;
  foreach(i, Arg; Args)
    args[i] = getArgument!(T, i)(L, i + 1);

  return callFunction!T(L, func, args);
}