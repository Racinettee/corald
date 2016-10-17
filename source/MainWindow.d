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

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		addNewSourceEditor(notebook);

		showAll();

    debugInstance = new GDB("test/fox");
		debugInstance.start();
	}
  ~this()
  {
		debugInstance.stop();
		writeln("Closing the app");
	}
	protected override bool windowDelete (Event e, Widget w)
	{
		writeln("Window exited");
		super.windowDelete(e, w);
		return true;
	}
	private alias GAsyncReadyCallback = extern (C) void function(GObject* source_object, GAsyncResult* res, gpointer user_data);
	private alias GProgressCallback = extern (C) void function(long, long, void*);
	private alias GProgressCallbackNotify = extern (C) void function(void*);
	alias gpointer = void*;
	void openFile(MenuItem)
	{
		auto fc = new FileChooserDialog("Choose a file to open", this,
			GtkFileChooserAction.OPEN, ["Open", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
		auto response = fc.run();
		if(response == ResponseType.CANCEL)
			return;
		
		string filepath = fc.getFilename();
		fc.destroy();
		auto sourceFile = new SourceFile();
		sourceFile.setLocation(File.parseName(filepath));
		auto sourceBuffer = new SourceBuffer(SourceLanguageManager.getDefault().guessLanguage(filepath, null));
		auto fileLoader = new SourceFileLoader(sourceBuffer, sourceFile);
		auto cancellation = new Cancellable();

		class UserData
		{
			string filepath;
			SourceFileLoader loader;
			Notebook notebook;
			SourceBuffer sourceBuf;
		}

		GAsyncReadyCallback finalize = function(GObject* sourceObj, GAsyncResult* result, gpointer userdat)
		{
			import coral.MemUtil : dealloc;

			auto userDat = cast(UserData)userdat;
			if(userDat.loader.loadFinish(new SimpleAsyncResult(cast(GSimpleAsyncResult*)result)))
				writeln(userDat.filepath ~ " loaded!");

			addNewSourceEditor(userDat.notebook, userDat.sourceBuf, userDat.filepath);

			userDat.notebook.setCurrentPage(-1);

			dealloc(userDat);
		};

		import coral.MemUtil : alloc;

		auto userDat = alloc!UserData;
		userDat.filepath = filepath;
		userDat.loader = fileLoader;
		userDat.notebook = notebook;
		userDat.sourceBuf = sourceBuffer;

		fileLoader.loadAsync(cast(int)GPriority.DEFAULT, cancellation,
			cast(GProgressCallback)0, cast(void*)0,
			cast(GProgressCallbackNotify)0, finalize, cast(void*)userDat);
	}

	void saveFileAs(MenuItem)
	{

	}

  IDebugger debugInstance;
	Builder builder;
	MenuBar mainMenu;
	Notebook notebook;
}
