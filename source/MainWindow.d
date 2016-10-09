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

import gio.File;
import gio.Cancellable;

import gsv.SourceFile;
import gsv.SourceBuffer;
import gsv.SourceFileLoader;
import gsv.SourceLanguageManager;

import gtkc.glibtypes : GPriority;

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
	private alias GAsyncReadyCallback = void function
    ( GObject* source_object, GAsyncResult* res, gpointer
    user_data );
	alias gpointer = void*;
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
		sourceFile.setLocation(File.parseName(filepath));
		auto sourceBuffer = new SourceBuffer(SourceLanguageManager.getDefault().guessLanguage(filepath, null));
		auto fileLoader = new SourceFileLoader(sourceBuffer, sourceFile);
		auto cancellation = new Cancellable();
		fileLoader.loadAsync(GPriority.DEFAULT, cancellation,	null, null,
			function(sourceObj, asyncRes, userDat
			{

			}), null);
	}
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;
}
