module coral.AppWindow;

import std.stdio;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gtk.Notebook;
import gtk.VBox;
import gsv.SourceView;

class AppWindow : MainWindow
{
	this()
	{
		super("Getting started with Gtkd");
		setSizeRequest(600, 400);

		builder = new Builder();
		notebook = new Notebook();

		if(!builder.addFromFile("interface/mainmenu.glade"))
			writeln("Could not load gladefile");

		mainMenu = cast(MenuBar)builder.getObject("mainMenu");

		auto vbox = new VBox(true, 0);
		vbox.packStart(mainMenu, true, true, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		notebook.

		showAll();
	}
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;
}
