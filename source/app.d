module coral.main;

import coral.window.appwindow;
import coral.plugin.framework;
import coral.debugger.manager;

import std.stdio : writeln;

import gtk.Main;

import reef.lua.state;

void main()
{
	try
	{
		initDebugManager();	
		string[] args = [];

		Main.init(args);

		initPluginSystem();
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
