module coral.lua.Lua;

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
		owner = true;
  }
	this(lua_State* L, bool isOwner=false)
	{
		luaState = L;
		owner = isOwner;
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
	private bool owner;
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
