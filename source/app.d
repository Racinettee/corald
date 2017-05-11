module coral.main;

import coral.window.appwindow;
import coral.plugin.framework;
import coral.debugger.manager;

import std.stdio : writeln;

import gtk.Main;
import glib.MainLoop;
import glib.MainContext;
import glib.Timeout;

import reef.lua.state;

State luaState;

void main()
{
	try
	{
		luaState = new State;
		luaState.openLibs();

		initDebugManager();	
		string[] args = [];

		Main.init(args);

		initPlugins(luaState);
		auto appWin = new AppWindow;

		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	finally
	{
		deinitDebugManager();
	}
}
