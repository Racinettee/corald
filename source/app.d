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
		string[] args;
		Main.init(args);
		auto appWin = new AppWindow();
		InitializePlugins();
		Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	debugManager.stopAll();
}
