module coral.Main;
import coral.AppWindow;

import std.stdio : writeln;

import gtk.Main;

void main()
{
	try
	{
		string[] args;
		Main.init(args);
		auto appWin = new AppWindow();
		Main.run();
		// Manually invoke destructor... as it doesn't seem to happen with derived MainWindow
		(cast(Object)appWin).destroy();
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
}
