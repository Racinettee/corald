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

	setRequire(globalState.state, "AppWindow", &registerAppWindow!AppWindow, 0);
	//globalState.require("AppWindow");
	pushInstance(globalState.state, initialWindow);
	globalState.setGlobal("mainWindow");

	//registerMainWindow(globalState, initialWindow);
	//registerTabLabel(globalState.state);
	//registerAppWindow(globalState.state);
	//registerMainWindow(globalState, initialWindow);
	
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
