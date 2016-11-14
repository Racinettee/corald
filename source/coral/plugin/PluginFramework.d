module coral.plugin.framework;

import coral.lua.state;
import coral.lua.userdata;
import coral.window.appwindow;

import std.json;
import std.file;
import std.string;
import std.path;

import lua.lua;
import lua.lualib;
import lua.lauxlib;

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
	import gtk.Widget : Widget;
	lua_CFunction openFile = (L) @trusted {
		try {
			AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
			const string filepath = cast(string)fromStringz(lua_tostring(L, 2));
			self.openFile(filepath);
		} catch (Exception) { }

		return 0;
	};
	lua_CFunction currentPage = (L) @trusted {
		try {
			AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
			
			lua_pushlightuserdata(L, self.currentPage.getWidgetStruct);
		} catch (Exception) {
			lua_pushnil(L);
		}
		return 1;
	};
	lua_CFunction currentTabLabel = (L) @trusted {
		try {
			AppWindow self = checkClassInstanceOf!AppWindow(L, 1);
			
			// Grabs lua_State, but doesnt take ownership
			State state = new State(L, false);

			import coral.component.tablabel : TabLabel;

			lua_CFunction noPath = (L) @trusted {
				try {
					TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
					lua_pushboolean(L, cast(int)self.noPath);
				} catch (Exception) {
					lua_pushnil(L);
				}
				return 1;
			};

			lua_CFunction getTitle = (L) @trusted {
				try {
					TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
					lua_pushstring(L, toStringz(self.title));
				} catch (Exception) {
					lua_pushnil(L);
				}
				return 1;
			};

			lua_CFunction getPath = (L) @trusted {
				try {
					TabLabel self = checkClassInstanceOf!TabLabel(L, 1);
					lua_pushstring(L, toStringz(self.fullPath));
				} catch (Exception) {
					lua_pushnil(L);
				}
				return 1;
			};

			luaL_Reg[] tabLabelMethods = [
				{"noPath", noPath},
				{"getTitle", getTitle},
				{"getPath", getPath},
				{null, null}
			];

			state.pushInstance(self.currentTabLabel, tabLabelMethods);

			//lua_pushlightuserdata(L, self.currentTabLabel.getWidgetStruct);
		} catch (Exception) {
			lua_pushnil(L);
		}
		return 1;
	};
	luaL_Reg[] mainWindowFunctions = [
		{"openFile", openFile},
		{"currentPage", currentPage},
		{"currentTabLabel", currentTabLabel},
		{null, null}
	];
	state.pushInstance(initialWindow, mainWindowFunctions);
	lua_pushlightuserdata(state.state, initialWindow.mainMenu.getMenuBarStruct);
	lua_setfield(state.state, -2, "menuBar");
	lua_pushlightuserdata(state.state, initialWindow.notebook.getNotebookStruct);
	lua_setfield(state.state, -2, "notebook");
	lua_pop(state.state, 1);

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
			import std.array;
			if(!exists(cast(string)array(chainPath("script",filename~".lua"))))
				if(!exists(cast(string)array(chainPath("script",filename~".moon"))))
					throw new Exception("Plugin: "~filename~" does not exist");
				
			globalState.require(entry["name"].str);
		}
	}
}
