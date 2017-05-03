module coral.plugin.framework;

import coral.window.appwindow;

import std.json;
import std.file;
import std.string;
import std.path;

import coral.plugin.callbackmanager;
import reef.lua.state;

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
    state.registerClass!AppWindow;
    state.push(initialWindow);
    state.setGlobal("mainWindow");
    import coral.component.tablabel;
    state.registerClass!TabLabel;
}

void requirePlugin(State state, string name, AppWindow window)
{
  state.getGlobal("require");
  state.push(name);
  import luad.c.lua : lua_pcall, lua_tostring;
  if((() @trusted => lua_pcall(state.state, 1, 1, 0))() != 0)
    throw new Exception("Lua error: "~cast(string)fromStringz(lua_tostring(state.state, -1)));
  CallbackManager.get().registerModule(state, "");
}

/// Call to initialize plugins
void initPlugins(State state, AppWindow initialWindow)
{
  state.addPath(absolutePath("script")~"/?.lua;"~absolutePath("script")~"/?.moon");
  state.addCPath(absolutePath(buildPath("dep","bin")));
  state.doString("local moonscript = require 'moonscript'");

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

      state.require(filename[0..lastIndexOf(filename, '.')]);
    }
  }
}
