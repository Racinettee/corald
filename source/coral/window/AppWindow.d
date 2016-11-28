﻿module coral.window.appwindow;

import coral.util.editor;
import coral.debugger.idebugger;
import coral.debugger.gdb;
import coral.debugger.manager;
import coral.component.tablabel;

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

/// Primary application window class
class AppWindow : MainWindow
{
	/// The default constructor.
	/// This is the only way to set up the window
	this(string title="CoralD", int width=600, int height=400)
	{
		super(title);
		setSizeRequest(width, height);

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

		//debugInstance = debugManager.newSession!GDB("test/fox", &gdbOutputHandler, &gdbOutputHandler);
		//debugInstance.setBreakpoint("test/fox.c", 7);
		//debugInstance.start();
	}
	~this()
	{
		//debugInstance.stop();
		writeln("Closing the app");
	}
	
	protected override bool windowDelete(Event e, Widget w)
	{
		//debugInstance.stop();
		return super.windowDelete(e, w);
	}

	void gdbOutputHandler(string line)
	{
		writeln(line);
	}

	/// Opens a file in this window, popping an open file dialog
	void openFile(MenuItem)
	{
		auto fc = new FileChooserDialog("Choose a file to open", this,
			GtkFileChooserAction.OPEN, ["Open", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
		immutable auto response = fc.run();
		if(response == ResponseType.CANCEL)
			return;
		
		string filepath = fc.getFilename();
		fc.destroy();

		openFile(filepath);
	}
	
	/// Opens a file in this window
	void openFile(string filepath)
	{
		coral.util.editor.openFile(notebook, filepath);
	}

	/// Saves the currently focused file, only pops
	/// save as dialog if file is new
	void saveFile(MenuItem m)
	{
		auto tabLabel = currentTabLabel;
		if(tabLabel.noPath)
		{
			saveFileAs(m);
			return;
		}
		coral.util.editor.saveFile(notebook, tabLabel.fullPath);
	}
	/// Saves the currently focused file, popping a save as dialog
	void saveFileAs(MenuItem)
	{
		auto fc = new FileChooserDialog("Choose a file to open", this,
			GtkFileChooserAction.SAVE, ["Save", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
		immutable auto response = fc.run();
		if(response == ResponseType.CANCEL)
		{
			fc.destroy();
			return;
		}

		string filepath = fc.getFilename();
		fc.destroy();

		import std.path : exists;
		import coral.util.windows : runOkCancelDialog;
		import gtkc.gtktypes : GtkResponseType;

		if(exists(filepath))
			if(runOkCancelDialog(this, "File you are saving already exists. Continue?") == GtkResponseType.CANCEL)
				return;

		coral.util.editor.saveFile(notebook, filepath);
	}
	
	/// Convenience method to get the currently displayed page
	@property Widget currentPage ()
	{
		return notebook.getNthPage(notebook.getCurrentPage);
	}

	/// Convenience method to get the tab label for the current page
	@property TabLabel currentTabLabel ()
	{
		return cast(TabLabel)notebook.getTabLabel(currentPage);
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

		menuItem = getItem!MenuItem(builder, "menusavefile");
		menuItem.addOnActivate(&saveFile);

		menuItem = getItem!MenuItem(builder, "menusavefileas");
		menuItem.addOnActivate(&saveFileAs);
	}
}
