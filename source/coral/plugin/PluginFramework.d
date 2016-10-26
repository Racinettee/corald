module coral.plugin.PluginFramework;

import coral.lua.Lua;

import std.json;
import std.file;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

private import std.path : absolutePath;

extern (C) int luaopen_lpeg (lua_State *L);

/// Call to initialize plugins
void initPlugins()
{
	//luaopen_lpeg(globalState.state);
	luaL_dostring(globalState.state,
		toStringz(
		"local projRoot = '"~absolutePath("script")~"'\n"
		"local binRoot = '"~absolutePath("dep/bin")~"'\n"
		"package.path = package.path .. ';' .. projRoot .. '/?.lua'\n"
		"package.cpath = package.cpath .. ';' .. binRoot .. '/?.so'"));
	//lua_pop(globalState.state, -1);
	globalState.require("moonscript");
	if(!exists("coralPlugins.json"))
		throw new Exception("File coralPlugins.json does not exist");
	JSONValue pluginFramework = parseJSON(cast(char[])read("coralPlugins.json"), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];
	
	foreach(entry; installedPlugins.array)
	{
		if(entry["enabled"].type == JSON_TYPE.TRUE)
		{
			string filename = entry["name"].str;

			if(!exists(filename))
				throw new Exception("Plugin: "~filename~" does not exist");
				
			globalState.loadFile(entry["name"].str);
		}
	}
}