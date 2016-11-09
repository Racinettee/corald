module coral.plugin.PluginFramework;

import std.json;
import std.file;
import std.string;
import std.path;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import coral.lua.Lua;
import coral.lua.UserData;
import coral.window.AppWindow;

void registerMainWindow(State state, AppWindow initialWindow)
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
	pushInstance(state.state, initialWindow, mainWindowFunctions);

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

	registerMainWindow(globalState, initialWindow);
	
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

			if(!exists(chainPath("script",filename~".lua")))
				if(!exists(chainPath("script",filename~".moon")))
					throw new Exception("Plugin: "~filename~" does not exist");
				
			globalState.require(entry["name"].str);
		}
	}
}
