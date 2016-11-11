module coral.main;
import coral.window.AppWindow;
import coral.plugin.framework;
import coral.debugger.DebugManager;

import std.stdio : writeln;

import gtk.Main;
import glib.MainLoop;
import glib.MainContext;
import glib.Timeout;

void main()
{
	try
	{
		initDebugManager();	
		string[] args = [];

		Main.init(args);

		auto appWin = new AppWindow;

		initPlugins(appWin);
		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	deinitDebugManager();
}
