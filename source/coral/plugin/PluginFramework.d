module coral.plugin.framework;

import coral.window.appwindow;

import std.json;
import std.file;
import std.string;
import std.path;

import coral.lua.state;

import gtk.Widget;

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
    state.registerClass!AppWindow;
}

/// Call to initialize plugins
void initPlugins(State state, AppWindow initialWindow)
{
  state.doString(
    "local projRoot = '"~absolutePath("script")~"'\n"
    "local binRoot = '"~absolutePath(buildPath("dep","bin"))~"'\n"
    "package.path = package.path .. ';' .. projRoot .. '/?.lua;' .. projRoot .. '/?.moon'\n"
    "package.cpath = package.cpath .. ';' .. binRoot .. '/?.so'");
    //lua_pop(state.state, -1); // ?

  state.require("moonscript");

  registerMainWindow(state, initialWindow);
  
  immutable string pluginFile = "coralPlugins.json";

  if(!exists(pluginFile))
      throw new Exception("File coralPlugins.json does not exist");
  JSONValue pluginFramework = parseJSON(cast(char[])read(pluginFile), JSONOptions.none);

  JSONValue installedPlugins = pluginFramework["plugins"];
  
  foreach(entry; installedPlugins.array)
  {
    if(entry["enabled"].type == JSON_TYPE.TRUE)
    {
      import std.array;
      string filename = cast(string)array(chainPath("script", entry["name"].str));

      if(!exists(filename))
        throw new Exception("Plugin: "~filename~" does not exist");

      state.doFile(filename);
    }
  }
}