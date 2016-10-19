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
	}
	catch(Exception e)
	{
		writeln(e.msg);
	}
}
