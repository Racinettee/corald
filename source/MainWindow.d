module coral.AppWindow;

import std.stdio;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Notebook;
import gtk.VBox;
import gtk.ScrolledWindow;
import gtk.FileChooserDialog;

import gsv.SourceBuffer;
import gsv.SourceFileLoader;

import coral.EditorUtil;

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

		mainMenu = getItem!MenuBar(builder, "mainMenu");
		
		auto menuItem = getItem!MenuItem(builder, "menunewfile");
		menuItem.addOnActivate((m)=>addNewSourceEditor(notebook));

		menuItem = getItem!MenuItem(builder, "menuopenfile");
		menuItem.addOnActivate(&openFile);

		menuItem = getItem!MenuItem(builder, "menuquit");
		menuItem.addOnActivate((m)=>close());

		menuItem = getItem!MenuItem(builder, "menunewwindow");
		menuItem.addOnActivate((m)=>new AppWindow().show());//&newWindow);

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		addNewSourceEditor(notebook);

		showAll();
	}
	void openFile(MenuItem)
	{
		auto fc = new FileChooserDialog("Choose a file to open", this,
			GtkFileChooserAction.OPEN, ["Open", "Cancel"],
			[ResponseType.ACCEPT, ResponseType.CANCEL]);
		auto response = fc.run();
		fc.destroy();
		if(response == ResponseType.CANCEL)
			return;
		
		string filepath = fc.getFilename();
		auto sourceFile = new SourceFile();
		sourceFile.setLocation(filepath);
		auto sourceBuffer = new SourceBuffer();
		auto fileLoader = new SourceFileLoader();
	}
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;
}
