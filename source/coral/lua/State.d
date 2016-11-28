module coral.lua.state;

import coral.lua.userdata;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

private import std.stdio : writeln;
private import std.string : toStringz, fromStringz;

/// The primary state
State globalState;

static this()
{
  globalState = new State();
  globalState.openLibs();
}

/// The state object
class State
{
  /// Default initialization
  this()
  {
    luaState = luaL_newstate();
	  isOwner = true;
  }
	this(lua_State* L, bool isOwner=false)
	{
		luaState = L;
		this.isOwner = isOwner;
	}
  ~this()
  {
		if(isOwner)
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
      printError(this);
  }
	void require(const string filename)
	{
		requireFile(luaState, toStringz(filename));
	}
  void doString(const string filename)
  {
    if(luaL_dostring(luaState, toStringz(filename)) != 0)
      printError(this);
  }
  void setGlobal(const string variableName)
  {
    lua_setglobal(luaState, toStringz(variableName));
  }
  /// Convert argument to string
  string toString(int index) nothrow
  {
    return cast(string)fromStringz(lua_tostring(luaState, index));
  }
  /// Convenience method to push user data to the stack
  //void pushInstance(T)(T instance)
  //{
  //  coral.lua.userdata.pushInstance(luaState, instance);
  //}
  /// Convenience method to push user data onto the lua stack
  void pushInstance(T)(T instance, const luaL_Reg[] methodTable)
  {
    coral.lua.userdata.pushInstance!T(luaState, instance, methodTable);
  }
  /// Get the underlying C object
  pure @safe @property lua_State *state () nothrow
  {
    return luaState;
  }
  private lua_State *luaState;
	private bool isOwner;
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
