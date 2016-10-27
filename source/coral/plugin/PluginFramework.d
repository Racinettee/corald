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
	if(!exists("coralPlugins.json"))
		throw new Exception("File coralPlugins.json does not exist");
	JSONValue pluginFramework = parseJSON(cast(char[])read("coralPlugins.json"), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];
	
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