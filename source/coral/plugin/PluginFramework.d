module coral.plugin.framework;

import coral.window.appwindow;

import std.json;
import std.file;
import std.string;
import std.path;

import coral.lua.state;

import gtk.Widget;

/// A test function. Sets up the very first window to interface
/// With the lua scripts that run
void registerMainWindow(State state, AppWindow initialWindow)
{
	
}

/// Call to initialize plugins
void initPlugins(State state, AppWindow initialWindow)
{
	state.doString(
		"local projRoot = '"~absolutePath("script")~"'\n"
		"local binRoot = '"~absolutePath(buildPath("dep","bin"))~"'\n"
		"package.path = package.path .. ';' .. projRoot .. '/?.lua;' .. projRoot .. '/?.moon'\n"
		"package.cpath = package.cpath .. ';' .. binRoot .. '/?.so'");
	//lua_pop(state.state, -1); // ?

	state.require("moonscript");

	registerMainWindow(state, initialWindow);
	//registerTabLabel(state);
	//registerAppWindow(state)
	//pushType!AppWindow(state.state);
	
	immutable string pluginFile = "coralPlugins.json";

	if(!exists(pluginFile))
		throw new Exception("File coralPlugins.json does not exist");
	JSONValue pluginFramework = parseJSON(cast(char[])read(pluginFile), JSONOptions.none);

	JSONValue installedPlugins = pluginFramework["plugins"];
	
	foreach(entry; installedPlugins.array)
	{
		if(entry["enabled"].type == JSON_TYPE.TRUE)
		{
			import std.array;
			string filename = cast(string)array(chainPath("script", entry["name"].str));
			
			if(!exists(filename))
				throw new Exception("Plugin: "~filename~" does not exist");
				
			state.doFile(filename);
		}
	}
}

void pushType(T)(lua_State* L) if(is(T == class) || is(T == struct))
{
	lua_newtable(L);

	enum metaName = T.mangleof ~ "_static";
	if(luaL_newmetatable(L, metaName.ptr) == 0)
	{
		lua_setmetatable(L, -2);
		return;
	}

	pushCallMetaConstructor!T(L);

	lua_newtable(L);

	pushValue(L, &AppWindow.showAll);
	lua_setfield(L, -2, "showAll");
	/*foreach(member; __traits(derivedMembers, T))
	{
		static if(is(typeof(__traits(getMember, T, member))) && isStaticMember!(T, member))
		{
			enum isFunction = is(typeof(mixin("T." ~ member)) == function);
			static if(isFunction)
				enum isProperty = (functionAttributes!(mixin("T." ~ member)) & FunctionAttribute.property);
			else
				enum isProperty = false;

			// TODO: support static properties
			static if(isFunction)
				pushValue(L, mixin("&T." ~ member));
			else
				pushValue(L, mixin("T." ~ member)); // TODO: this needs to push a function that returns the member.. no?

			lua_setfield(L, -2, member.ptr);
		}
	}*/

	lua_setfield(L, -2, "__index");

	lua_setmetatable(L, -2);
}