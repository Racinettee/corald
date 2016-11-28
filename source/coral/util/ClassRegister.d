/// This module is about registering classes to lua
module coral.util.classregister;

import std.string;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import coral.lua.state;
import coral.lua.userdata;
import coral.util.memory;
import coral.window.appwindow : AppWindow;

/// Register the application window class
/// making the class requirable
int registerAppWindow(T)(lua_State* state) nothrow
{
  import gtk.Widget : Widget;

  lua_CFunction newAppWindow = (L) @trusted {
    try {
      immutable int nargs = lua_gettop(L);

      if(nargs != 3) {
        writeln("Expected 3 arguments to app window");
        throw new Exception("Lua AppWindow ctor");
      }
      // String, int, int - title, width, height
      // Create a new window with those properties
      immutable string title = cast(string)fromStringz(lua_tostring(L, 1));
      immutable int width = cast(int)lua_tointeger(L, 2);
      immutable int height = cast(int)lua_tointeger(L, 3);
      AppWindow win = alloc!AppWindow(title, width, height);

      pushInstance(L, win);
      lua_pushlightuserdata(L, win.mainMenu.getMenuBarStruct);
      lua_setfield(L, -2, "menuBar");
      lua_pushlightuserdata(L, win.notebook.getNotebookStruct);
      lua_setfield(L, -2, "notebook");
    } catch (Exception) {
      lua_pushnil(L);
    }
    return 1;
  };

  luaL_Reg[] methodTable = [
    {"new", newAppWindow},
    {null, null}
  ];

  lua_CFunction openFile = (L) @trusted {
    try {
      AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
      const string filepath = cast(string)fromStringz(lua_tostring(L, 2));
      self.openFile(filepath);
    } catch (Exception) { }

    return 0;
  };
  lua_CFunction currentPage = (L) @trusted {
    try {
      AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
      lua_pushlightuserdata(L, self.currentPage.getWidgetStruct);
    } catch (Exception) {
      lua_pushnil(L);
    }
    return 1;
  };
  lua_CFunction currentTabLabel = (L) @trusted {
    try {
      AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
      pushInstance(L, self.currentTabLabel);
    } catch (Exception) {
      lua_pushnil(L);
    }
    return 1;
  };
  lua_CFunction gcAppWin = (L) @trusted {
    try {
      dealloc(checkClassInstanceOf!AppWindow(L, 1));
    } catch (Exception) { }
    return 0;
  };
  luaL_Reg[] metaTable = [
    {"openFile", openFile},
    {"currentPage", currentPage},
    {"currentTabLabel", currentTabLabel},
    {"__gc", gcAppWin},
    {null, null}
  ];
  return registerClass!AppWindow(state, methodTable, metaTable);
}

/// Register the tablabel class
void registerTabLabel(lua_State* state)
{
  import coral.component.tablabel : TabLabel;
  import coral.window.appwindow : AppWindow;
  if(luaL_newmetatable(state, metatableNamez!AppWindow))
  {
    lua_CFunction noPath = (L) @trusted {
      try {
        TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
        lua_pushboolean(L, cast(int)self.noPath);
      } catch (Exception) {
        lua_pushnil(L);
      }
      return 1;
    };
    lua_CFunction getTitle = (L) @trusted {
      try {
        TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
        lua_pushstring(L, toStringz(self.title));
      } catch (Exception) {
        lua_pushnil(L);
      }
      return 1;
    };
    lua_CFunction getPath = (L) @trusted {
      try {
        TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
        lua_pushstring(L, toStringz(self.fullPath));
      } catch (Exception) {
        lua_pushnil(L);
      }
      return 1;
    };
    luaL_Reg[] methodTable = [
      {"noPath", noPath},
      {"getTitle", getTitle},
      {"getPath", getPath},
      {null, null}
    ];
    luaL_setfuncs(state, methodTable.ptr, 0);
    lua_pushvalue(state, -1);
    lua_setfield(state, -1, "__index");
  }
  lua_pop(state, 1);
}