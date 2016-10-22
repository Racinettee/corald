module coral.lua.Lua;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

enum LuaType
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

struct Nil{}

public Nil nil;

class State
{
  this()
  {
    luaState = luaL_newstate();
  }
  ~this()
  {
    lua_close(luaState);
  }
  void openLibs()
  {
    luaL_openlibs(luaState);
  }
  /// Loads a file and runs it
  void loadFile(const string filename)
  {

  }
  pure @safe @property lua_State *state () nothrow
  {
    return luaState;
  }
  private lua_State *luaState;
}

private import std.stdio : writeln;
private import std.string : fromStringz;

void printError(State state)
{
  writeln(fromStringz(lua_tostring(state.state, -1)));
}