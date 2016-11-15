/// This module is about registering classes to lua
module coral.util.classregister;

import coral.lua.state;
import coral.lua.userdata;

/// Register the application window class
void registerAppWindonw()
{
  import gtk.Widget : Widget;
  import coral.window.appwindow : AppWindow;

  if(luaL_newmetatable(state, metatableNamez!AppWindow))
  {
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

      } catch (Exception) {
        lua_pushnil(L);
      }
      return 1;
    };
    luaL_Reg[] methodTable = [
      {"openFile", openFile},
      {"currentPage", currentPage},
      {"currentTabLabel", currentTabLabel},
      {null, null}
    ];
    luaL_setfuncs(state, methodTable.ptr, 0);
    lua_pushvalue(state, -1);
    lua_setfield(state, -1, "__index");
  }
  lua_pop(state, 1);
}

/// Register the tablabel class
void registerTabLabel(State state)
{
  import coral.component.tablabel : TabLabel;
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