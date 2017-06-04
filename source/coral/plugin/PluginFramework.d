module coral.plugin.framework;

import std.json;
import std.file;
import std.string;
import std.path;

import coral.plugin.callbackmanager;
import reef.lua.state;

import coral.window.appwindow;
import coral.window.scrolledfiletree;
import coral.component.filetree;
import coral.component.tablabel;
import coral.component.sourceeditor;

State luaState;

void initPluginSystem()
{
    luaState = new State;
    luaState.openLibs();
    initPlugins(luaState);
    CallbackManager.get().callHandlers(luaState, CallbackManager.BEFORE_START, null);
}

void closePluginSystem()
{
    CallbackManager.get().callHandlers(luaState, CallbackManager.BEFORE_END, null);
}

void registerClasses(State state)
{
    state.registerClass!AppWindow;
    state.registerClass!TabLabel;
    state.registerClass!ScrolledFileTree;
    state.registerClass!FileTree;
}

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
    state.push(initialWindow);
    state.setGlobal("mainWindow");
}

void requirePlugin(State state, string name)
{
  state.getGlobal("require");
  state.push(name);
  import luad.c.lua : lua_pcall, lua_tostring;
  if((() @trusted => lua_pcall(state.state, 1, 1, 0))() != 0)
    throw new Exception("Lua error: "~cast(string)fromStringz(lua_tostring(state.state, -1)));
  CallbackManager.get().registerModule(state, "");
}

/// Call to initialize plugins
void initPlugins(State state)
{
  state.addPath(absolutePath("script")~"/?.lua;");//~absolutePath("script")~"/?.moon");
  state.addCPath(absolutePath(buildPath("dep","bin")));
  //state.doString("local moonscript = require 'moonscript'");

  registerClasses(state);
  
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

      //state.require(filename[0..lastIndexOf(filename, '.')]);
      requirePlugin(state, filename[0..lastIndexOf(filename, '.')]);
    }
  }
}
