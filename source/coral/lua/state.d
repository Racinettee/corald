module coral.lua.state;

import std.string;

import coral.lua.c.all;
import coral.lua.classes : registerClassType = registerClass;
import coral.lua.stack;

class State
{
  this()
  {
    is_owner = true;
    luastate = luaL_newstate;
  }
  this(lua_State* L)
  {
    is_owner = false;
    luastate = L;
  }
  ~this()
  {
    if(is_owner)
      lua_close(state);
  }
  void doFile(string file)
  {
    if(luaL_dofile(luastate, toStringz(file)) != 0)
      printError(this);
  }
  void doString(string line)
  {
    if(luaL_dostring(luastate, toStringz(line)) != 0)
      printError(this);
  }
  void openLibs()
  {
    luaL_openlibs(luastate);
  }
  void require(const string filename)
  {
    requireFile(luastate, toStringz(filename));
  }
  void registerClass(T)()
  {
    registerClassType!T(this);
  }
  void push(T)(T value)
  {
    pushValue!T(luastate, value);
  }
  @property
  lua_State* state() { return luastate; }
  private lua_State* luastate;
  bool is_owner;
}

import std.stdio : writeln;
package void printError(State state)
{
  writeln(fromStringz(lua_tostring(state.state, -1)));
}
private:
int requireFile (lua_State *L, const char *name) {
  lua_getglobal(L, "require");
  lua_pushstring(L, name);
  return report(L, lua_pcall(L, 1, 1, 0));
}
int report(lua_State* L, int status)
{
	if (status && !lua_isnil(L, -1)) {
    string msg = cast(string)fromStringz(lua_tostring(L, -1));
    if (msg == null) msg = "(error object is not a string)";
		writeln(msg);
		lua_pop(L, 1);
	}
	return status;
}