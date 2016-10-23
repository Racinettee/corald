module coral.plugin.PluginFramework;

import coral.lua.Lua;

import std.json;
import std.file;

/// Call to initialize plugins
void InitializePlugins()
{
	JSONValue pluginFramework = parseJSON(read("coralPlugins.json"), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];
	
	foreach(entry; installedPlugins.array)
	{
		if(cast(bool)entry["enabled"].integer == true)
			globalState.loadFile(entry["name"].toString());
	}
}