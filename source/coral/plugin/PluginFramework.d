module coral.plugin.PluginFramework;

import coral.lua.Lua;

import std.json;
import std.file;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

private import std.path : absolutePath;

/// Call to initialize plugins
void initPlugins()
{
	luaL_dostring(globalState.state,
		toStringz("local projRoot = '"~absolutePath("script")~"'\n"
		"package.path = package.path .. ';' .. projRoot .. '/?.lua'"));
	lua_pop(globalState.state, -1);
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