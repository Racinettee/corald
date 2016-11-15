module coral.plugin.framework;

import coral.lua.state;
import coral.lua.userdata;
import coral.window.appwindow;
import coral.util.classregister;

import std.json;
import std.file;
import std.string;
import std.path;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
//	state.pushInstance(self.currentTabLabel, tabLabelMethods);
	state.pushInstance(initialWindow);
	lua_pushlightuserdata(state.state, initialWindow.mainMenu.getMenuBarStruct);
	lua_setfield(state.state, -2, "menuBar");
	lua_pushlightuserdata(state.state, initialWindow.notebook.getNotebookStruct);
	lua_setfield(state.state, -2, "notebook");
	lua_pop(state.state, 1);

	state.setGlobal("mainWindow");
}

/// Call to initialize plugins
void initPlugins(AppWindow initialWindow)
{
	globalState.doString(
		"local projRoot = '"~absolutePath("script")~"'\n"
		"local binRoot = '"~absolutePath(buildPath("dep","bin"))~"'\n"
		"package.path = package.path .. ';' .. projRoot .. '/?.lua;' .. projRoot .. '/?.moon'\n"
		"package.cpath = package.cpath .. ';' .. binRoot .. '/?.so'");
	//lua_pop(globalState.state, -1); // ?

	globalState.require("moonscript");

	//registerMainWindow(globalState, initialWindow);
	registerTabLabel(globalState);
	registerAppWindow(globalState);
	
	immutable string pluginFile = "coralPlugins.json";

	if(!exists(pluginFile))
		throw new Exception("File coralPlugins.json does not exist");
	JSONValue pluginFramework = parseJSON(cast(char[])read(pluginFile), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];
	
	foreach(entry; installedPlugins.array)
	{
		if(entry["enabled"].type == JSON_TYPE.TRUE)
		{
			string filename = entry["name"].str;
			import std.array;
			if(!exists(cast(string)array(chainPath("script",filename~".lua"))))
				if(!exists(cast(string)array(chainPath("script",filename~".moon"))))
					throw new Exception("Plugin: "~filename~" does not exist");
				
			globalState.require(entry["name"].str);
		}
	}
}
