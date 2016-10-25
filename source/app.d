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
		initPlugins();		
		string[] args;
		Main.init(args);
		auto appWin = new AppWindow();
		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	deinitDebugManager();
}
