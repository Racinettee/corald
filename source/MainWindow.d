module coral.AppWindow;

import std.stdio : writeln;

import gtk.MainWindow;
import gtk.Builder;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Notebook;
import gtk.VBox;
import gtk.ScrolledWindow;
import gtk.FileChooserDialog;
import gtk.Widget;

import gdk.Event;

import gio.File;
import gio.Cancellable;
import gio.SimpleAsyncResult;

import gsv.SourceFile;
import gsv.SourceBuffer;
import gsv.SourceFileLoader;
import gsv.SourceLanguageManager;

import gtkc.glibtypes : GPriority;

import coral.EditorUtil;

import coral.debugger.IDebugger;
import coral.debugger.GDB;

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
		
		hookMenuItems();

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		addNewSourceEditor(notebook);

		showAll();

    debugInstance = new GDB("test/fox");
		debugInstance.setBreakpoint("test/fox.c", 7);
		debugInstance.start();
	}
  ~this()
  {
		debugInstance.stop();
		writeln("Closing the app");
	}
	
	void openFile(MenuItem)
	{
		auto fc = new FileChooserDialog("Choose a file to open", this,
			GtkFileChooserAction.OPEN, ["Open", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
		auto response = fc.run();
		if(response == ResponseType.CANCEL)
			return;
		
		string filepath = fc.getFilename();
		fc.destroy();

		coral.EditorUtil.openFile(notebook, filepath);
	}

	void saveFileAs(MenuItem)
	{

	}

  IDebugger debugInstance;
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;

	private void hookMenuItems()
	{
		auto menuItem = getItem!MenuItem(builder, "menunewfile");
		menuItem.addOnActivate((m)=>addNewSourceEditor(notebook));

		menuItem = getItem!MenuItem(builder, "menuopenfile");
		menuItem.addOnActivate(&openFile);

		menuItem = getItem!MenuItem(builder, "menuquit");
		menuItem.addOnActivate((m)=>close());

		menuItem = getItem!MenuItem(builder, "menunewwindow");
		menuItem.addOnActivate((m)=>new AppWindow().show());

		menuItem = getItem!MenuItem(builder, "menusavefileas");
		menuItem.addOnActivate(&saveFileAs);
	}
}
