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

//int registerAppWindow(lua_State* L)
//{
//  lua_newtable(L);
//  luaL_setfuncs(L, )
//}

/// Create an instance that is a pointer in lua
T* pushNewInstance(T)(lua_State* state)
{
  T* obj = cast(T*)lua_newuserdata(L, (T*).sizeof);
  luaL_getmetatable(state, metatableNamez!T);
  lua_setmetatable(state, -2);
  return obj;
}
/// Create a new instaance that is a pointer in lua, but assign it to an existing instance
T* pushInstance(T)(lua_State* state, T instance)
{
  T* obj = pushNewInstance!T(state);
  *obj = instance;
  return obj;
}

/// Register the application window class
void requireAppWindow(T)(lua_State* state)
{
  import gtk.Widget : Widget;

  lua_CFunction newAppWindow = (L) @trusted {
    try {
      immutable int nargs = lua_gettop(L);

      if(nargs != 3) {
        writeln("Expected 3 arguments to app window");
        throw new Exception;
      }


        // String, int, int - title, width, height
        // Create a new window with those properties
    } catch (Exception) {
      lua_pushnil(L);
    }
    return 1;
  };
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

    } catch (Exception) {

    }
    return 0;
  };
  luaL_Reg[] metaTable = [
    {"openFile", openFile},
    {"currentPage", currentPage},
    {"currentTabLabel", currentTabLabel},
    {null, null}
  ];
  registerClass!AppWindow(state, )
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