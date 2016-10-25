module coral.lua.Lua;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import std.traits;

private import std.stdio : writeln;
private import std.string : toStringz, fromStringz;

/// The primary state
State globalState;

static this()
{
  globalState = new State();
  globalState.openLibs();
}

enum Type
{
	///string
	String = LUA_TSTRING,
	///number
	Number = LUA_TNUMBER,
	//table
	Table = LUA_TTABLE,
	///nil
	Nil = LUA_TNIL,
	///boolean
	Boolean = LUA_TBOOLEAN,
	///function
	Function = LUA_TFUNCTION,
	///userdata
	Userdata = LUA_TUSERDATA,
	///ditto
	LightUserdata = LUA_TLIGHTUSERDATA,
	///thread
	Thread = LUA_TTHREAD
}

struct Nil {}

public Nil nil;

/// The state object
class State
{
  /// Default initialization
  this()
  {
    luaState = luaL_newstate();
  }
  ~this()
  {
    lua_close(luaState);
  }
  /// Call this to get all the default libs on this state
  void openLibs()
  {
    luaL_openlibs(luaState);
  }
  /// Loads a file and runs it
  void loadFile(const string filename)
  {
    int result = luaL_loadfile(luaState, toStringz(filename));

    if(result != LUA_OK)
    {
      printError(this);
      return;
    }

    result = lua_pcall(luaState, 0, LUA_MULTRET, 0);

    if(result != LUA_OK)
    {
      printError(this);
      return;
    }
  }
	void require(const string filename)
	{
		requireFile(luaState, toStringz(filename));
	}
  /// Get the underlying C object
  pure @safe @property lua_State *state () nothrow
  {
    return luaState;
  }
  private lua_State *luaState;
}

/// Call this get an error message printed
void printError(State state)
{
  import std.stdio : writeln;
  writeln(fromStringz(lua_tostring(state.state, -1)));
}

private int report(lua_State* L, int status)
{
	if (status && !lua_isnil(L, -1)) {
    string msg = cast(string)fromStringz(lua_tostring(L, -1));
    if (msg == null) msg = "(error object is not a string)";
		writeln(msg);
		lua_pop(L, 1);
	}
	return status;
}

int requireFile (lua_State *L, const char *name) {
  lua_getglobal(L, "require");
  lua_pushstring(L, name);
  return report(L, lua_pcall(L, 1, 1, 0));
}

/**
 * Represents a reference to a Lua value of any type.
 * It contains only the bare minimum of functionality which all Lua values support.
 * For a generic reference type with more functionality, see $(DPREF dynamic,LuaDynamic).
 */
struct LuaObject
{
	private:
	int r = LUA_REFNIL;
	lua_State* L = null;

	package:
	this(lua_State* L, int idx)
	{
		this.L = L;

		lua_pushvalue(L, idx);
		r = luaL_ref(L, LUA_REGISTRYINDEX);
	}

	void push() nothrow
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, r);
	}

	static void checkType(lua_State* L, int idx, int expectedType, const(char)* expectedName)
	{
		int t = lua_type(L, idx);
		if(t != expectedType)
		{
			luaL_error(L, "attempt to create %s with %s", expectedName, lua_typename(L, t));
		}
	}

	public:
	@trusted this(this)
	{
		push();
		r = luaL_ref(L, LUA_REGISTRYINDEX);
	}

	@trusted nothrow ~this()
	{
		luaL_unref(L, LUA_REGISTRYINDEX, r);
	}

	/// The underlying $(D lua_State) pointer for interfacing with C.
	lua_State* state() pure nothrow @safe @property
	{
		return L;
	}

	/**
	 * Release this reference.
	 *
	 * This reference becomes a nil reference.
	 * This is only required when you want to _release the reference before the lifetime
	 * of this $(D LuaObject) has ended.
	 */
	void release() pure nothrow @safe
	{
		r = LUA_REFNIL;
		L = null;
	}

	/**
	 * Type of referenced object.
	 * See_Also:
	 *	 $(MREF LuaType)
	 */
	@property Type type() @trusted nothrow
	{
		push();
		auto result = cast(Type)lua_type(state, -1);
		lua_pop(state, 1);
		return result;
	}

	/**
	 * Type name of referenced object.
	 */
	@property string typeName() @trusted /+ nothrow +/
	{
		import core.stdc.string : strlen;
		push();
		const(char)* cname = luaL_typename(state, -1); // TODO: Doesn't have to use luaL_typename, i.e. no copy
		auto name = cname[0.. strlen(cname)].idup;
		lua_pop(state, 1);
		return name;
	}

	/// Boolean whether or not the referenced object is nil.
	@property bool isNil() pure nothrow @safe
	{
		return r == LUA_REFNIL;
	}

	/**
	 * Convert the referenced object into a textual representation.
	 *
	 * The returned string is formatted in the same way the Lua $(D tostring) function formats.
	 *
	 * Returns:
	 * String representation of referenced object
	 */
	string toString() @trusted
	{
		push();

		size_t len;
		const(char)* cstr = luaL_tolstring(state, -1, &len);
		auto str = cstr[0 .. len].idup;

		lua_pop(state, 2);
		return str;
	}

	/**
	 * Attempt _to convert the referenced object _to the specified D type.
	 * Examples:
	 -----------------------
	auto results = lua.doString(`return "hello!"`);
	assert(results[0].to!string() == "hello!");
	 -----------------------
	 */
	T to(T)()
	{
		static void typeMismatch(lua_State* L, int t, int e)
		{
			luaL_error(L, "attempt to convert LuaObject with type %s to a %s", lua_typename(L, t), lua_typename(L, e));
		}

		push();
		return popValue!(T, typeMismatch)(state);
	}

	/**
	 * Compare this object to another with Lua's equality semantics.
	 * Also returns false if the two objects are in different Lua states.
	 */
	bool opEquals(T : LuaObject)(ref T o) @trusted
	{
		if(o.state != this.state)
			return false;

		push();
		o.push();
		scope(success) lua_pop(state, 2);

		return lua_equal(state, -1, -2);
	}
}

void pushValue(T)(lua_State* L, T value)
{
  static if(is(T == bool))
    lua_pushboolean(L, cast(bool)value);
  
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
}