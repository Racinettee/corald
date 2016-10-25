module coral.plugin.PluginFramework;

import coral.lua.Lua;

import std.json;
import std.file;

/// Call to initialize plugins
void initPlugins()
{
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