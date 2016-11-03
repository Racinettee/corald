module coral.Main;
import coral.window.AppWindow;
//import coral.plugin.PluginFramework;
import coral.debugger.DebugManager;
import coral.application.Application;

import std.stdio : writeln;

//import gtk.Main;

void main()
{
	try
	{
		initDebugManager();	
		string[] args;

		coralApplication = new Application;
		coralApplication.run();
		//Main.init(args);
		//auto appWin = new AppWindow();
		//initPlugins(appWin);
		//Main.run();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
	deinitDebugManager();
}
