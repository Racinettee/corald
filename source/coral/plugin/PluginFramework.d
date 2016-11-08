module coral.plugin.PluginFramework;

import coral.lua.Lua;
import coral.window.AppWindow;

import std.json;
import std.file;
import std.string;
import std.path : absolutePath;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import coral.lua.Lua;
import coral.lua.UserData;

void registerMainWindow(State luaState, AppWindow initialWindow)
{
	lua_CFunction openFile = (L) @trusted {
		try {
			AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
			const string filepath = cast(string)fromStringz(lua_tostring(L, 2));
			self.openFile(filepath);
		} catch (Exception) { }

		return 0;
	};
	luaL_Reg[] mainWindowFunctions = [
			{"openFile", openFile},
			{null, null}
		];
	pushInstance(luaState.state, initialWindow, mainWindowFunctions);

	lua_setglobal(luaState.state, "mainWindow");
	writeln("Address of app window: ", &initialWindow);
}

/// Call to initialize plugins
void initPlugins(AppWindow initialWindow)
{
	//luaop                                                                                                                                en_lpeg(globalState.state);
	int result = luaL_dostring(globalState.state,
		toStringz(
		"local projRoot = '"~absolutePath("script")~"'\n"
		"local binRoot = '"~absolutePath("dep/bin")~"'\n"
		"package.path = package.path .. ';' .. projRoot .. '/?.lua;' .. projRoot .. '/?.moon'\n"
		"package.cpath = package.cpath .. ';' .. binRoot .. '/?.so'"));
	//lua_pop(globalState.state, -1);
	if(result != 0)
		printError(globalState);
	globalState.require("moonscript");

	registerMainWindow(globalState, initialWindow);
	
	immutable string pluginFile = "coralPlugins.json";

	if(!exists(pluginFile))
		throw new Exception("File coralPlugins.json does not exist");
	JSONValue pluginFramework = parseJSON(cast(char[])read(pluginFile), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];

	//pushValue(globalState.state, initialWindow);
	//lua_setglobal(globalState.state, "mainWindow");
	
	foreach(entry; installedPlugins.array)
	{
		if(entry["enabled"].type == JSON_TYPE.TRUE)
		{
			string filename = entry["name"].str;

			//if(!exists(filename))
			//	throw new Exception("Plugin: "~filename~" does not exist");
				
			globalState.require(entry["name"].str);
		}
	}
}
