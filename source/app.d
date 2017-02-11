module coral.main;

import coral.window.appwindow;
import coral.plugin.framework;
import coral.debugger.manager;

import std.stdio : writeln;

import gtk.Main;
import glib.MainLoop;
import glib.MainContext;
import glib.Timeout;

import luad.all;

void main()
{
	try
	{
		auto lua = new LuaState;
		lua.openLibs();

		initDebugManager();	
		string[] args = [];

		Main.init(args);

		auto appWin = new AppWindow;

		initPlugins(lua, appWin);
		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	deinitDebugManager();
}
