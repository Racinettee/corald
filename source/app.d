module coral.Main;
import coral.window.AppWindow;
import coral.plugin.PluginFramework;
import coral.debugger.DebugManager;

import std.stdio : writeln;

import gtk.Main;

void main()
{
	try
	{
		initDebugManager();	
		string[] args;
		Main.init(args);
		auto appWin = new AppWindow();
		initPlugins();
		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	deinitDebugManager();
}
