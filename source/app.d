module coral.Main;
import coral.window.AppWindow;
import coral.plugin.PluginFramework;
import coral.debugger.DebugManager;
import coral.application.Application;

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
		string[] args = ["script/moonhello.moon"];

		Main.init(args);

		Main.iteration();

		//bool deligate() initPluginsDeligate;
		auto appWin = new AppWindow;
		auto initPluginsDeligate = () {
			initPlugins(appWin);
			return false;
		};

		new Timeout(1000U, () => initPluginsDeligate());

		Main.run();
		/*auto mainContext = new MainContext;
		mainContext.doref();
		auto mainLoop = new MainLoop(mainContext, true);
		mainLoop.doref();
		initPlugins(new AppWindow());
		mainLoop.run();
		mainLoop.unref();
		mainContext.unref();*/
//		coralApplication = new CoralApp;
//		coralApplication.run(args);
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
