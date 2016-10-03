module coral.AppWindow;

import std.stdio;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gsv.SourceView;

class AppWindow : MainWindow
{
	this()
	{
		super("Getting started with Gtkd");
		setSizeRequest(600, 400);

		builder = new Builder();

		if(!builder.addFromFile("interface/mainmenu.glade"))
			writeln("Could not load gladefile");

		mainMenu = cast(MenuBar)builder.getObject("mainMenu");
		add(mainMenu);

		showAll();
	}
	Builder builder;
	MenuBar mainMenu;
}
