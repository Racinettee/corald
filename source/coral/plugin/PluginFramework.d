module coral.plugin.PluginFramework;

import coral.lua.Lua;
import coral.window.AppWindow;

import std.json;
import std.file;
import std.path : absolutePath;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

import coral.lua.Lua;

const char* metatableName = "AppWindowMetaTable";

void registerMainWindow(State luaState, AppWindow initialWindow)
{
	lua_State* state = luaState.state;

	AppWindow* window = cast(AppWindow*)lua_newuserdata(
		state, initialWindow.sizeof);
	*window = initialWindow;

	if(luaL_newmetatable(state, metatableName))
	{
		lua_CFunction openFile = (L) @trusted {
			try {
				writeln("gracias señor esqueleto!");
			} catch (Exception) { }
			AppWindow* selfPtr = cast(AppWindow*)luaL_checkudata(
				L, 1, metatableName);

			return 0;
		};

		lua_pushvalue(state, -1);
		lua_setfield(state, -2, "__index");

		luaL_Reg[] mainWindowFunctions = [
			{"openFile", openFile},
			{null, null}
		];

		luaL_setfuncs(state, mainWindowFunctions.ptr, 0);

		lua_setmetatable(state, -2);
		lua_setglobal(state, "mainWindow");
	}
	writeln("Address of app window: ", &(*window));
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
