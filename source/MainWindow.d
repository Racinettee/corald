module coral.AppWindow;

import std.stdio;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Notebook;
import gtk.VBox;
import gtk.ScrolledWindow;

import coral.TabLabel;
import coral.SourceEditor;

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

		mainMenu = getItem!MenuBar("mainMen");
		
		auto menuItem = getItem!MenuItem("menunewfile");
		menuItem.addOnActivate((m)=>writeln("New item clicked"));

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		auto scrolledWin = new SourceEditor();
		notebook.appendPage(scrolledWin, new TabLabel("dub.json", scrolledWin, "./dub.json"));

		showAll();
	}
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;

	private T getItem(T)(string n)
	{
		T item = cast(T)builder.getObject(n);
		if(item is null)
			throw new Exception("Failed to get object: "~n~" from builder");
		return item;
	}
}
