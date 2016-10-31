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

void registerMainWindow(State luaState, AppWindow initialWindow)
{
	const char* metatable = "windowMetaTable";

	lua_State* state = luaState.state;
	AppWindow* window = cast(AppWindow*)lua_newuserdata(
		state, (AppWindow*).sizeof);
	*window = initialWindow;

	if(luaL_newmetatable(state, "windowMetaTable"))
	{
		lua_pushvalue(state, -1);
		lua_setfield(state, -2, "__index");

		lua_CFunction openFile = (L) {
			AppWindow* selfPtr = cast(AppWindow*)luaL_checkudata(
				L, 1, "windowMetaTable");
		
			return 0;
		};

		luaL_Reg[] mainWindowFunctions = [
			{"openFile", openFile},
			{null, null}
		];

		luaL_register(state, 0, mainWindowFunctions);
	}
	lua_setmetatable(state, -2);
	lua_setglobal(state, "mainWindow");
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
