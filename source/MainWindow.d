module coral.AppWindow;

import std.stdio;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gtk.Notebook;
import gtk.VBox;
import gtk.ScrolledWindow;
import gsv.SourceView;

import coral.TabLabel;

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

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		auto scrolledWin = new ScrolledWindow();
		notebook.appendPage(scrolledWin, new TabLabel("dub.json", scrolledWin, "./dub.json"));

		showAll();
	}
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;
}
