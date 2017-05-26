module coral.window.appwindow;

import coral.util.editor;
import coral.debugger.idebugger;
import coral.debugger.gdb;
import coral.debugger.manager;
import coral.component.tablabel;
import coral.window.scrolledfiletree;

import std.stdio : writeln;

import gtk.AccelGroup;
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

import reef.lua.attrib;
import reef.lua.state : State;

import std.file : getcwd;

import coral.plugin.framework : luaState;

/// Primary application window class
@LuaExport("AppWindow")
class AppWindow : MainWindow
{
	@LuaExport("", MethodType.ctor)
	this() { this("Starting out"); }
	@LuaExport("", MethodType.ctor)
	public this(string title)
	{
		super(title);
		setSizeRequest(600, 400);

		self = this;
		accelGroup = new AccelGroup;
		builder = new Builder;
		notebook = new Notebook;

		if(!builder.addFromFile("interface/mainmenu.glade"))
			writeln("Could not load gladefile");

		mainMenu = getItem!MenuBar(builder, "mainMenu");
		
		hookMenuItems();

		//treeview = new ScrolledFileTree(getcwd);

		auto vbox = new VBox(false, 0);
		vbox.packStart(mainMenu, false, false, 0);
		//vbox.packStart(treeview, true, true, 0);
		vbox.packEnd(notebook, true, true, 0);
		add(vbox);

		addNewSourceEditor(notebook);
		
		auto newWindowArgs(State s) {
			writeln("New window args function");
			s.push(this);
			return 1;
		}
		import coral.plugin.callbackmanager : CallbackManager;
		CallbackManager.get().callHandlers(luaState, CallbackManager.EDITOR_CREATED, (s) => newWindowArgs(s));

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
	/// Opens a file in this window
	@LuaExport("openFile", MethodType.method)
	public void openFile(string filepath)
	{
		coral.util.editor.openFile(notebook, filepath);
	}

	/// Opens a file in this window, popping an open file dialog
	@LuaExport("openFileMI", MethodType.method)
	public void openFileMenuItem(MenuItem)
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
	

	/// Saves the currently focused file, only pops
	/// save as dialog if file is new
	@LuaExport("saveFile", MethodType.method)
	public void saveFile(MenuItem m)
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
	@LuaExport("saveFileAs", MethodType.method)
	void saveFileAs(MenuItem mi)
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

		if(exists(filepath) && runOkCancelDialog(this, "File you are saving already exists. Continue?") == GtkResponseType.CANCEL)
			return;

		coral.util.editor.saveFile(notebook, filepath);
	}
	
	/// Convenience method to get the currently displayed page
	@LuaExport("currentPage", MethodType.method, "getWidgetStruct()", RetType.lightud)
	@property Widget currentPage ()
	{
		return notebook.getNthPage(notebook.getCurrentPage);
	}

	/// Convenience method to get the tab label for the current page
	@property TabLabel currentTabLabel ()
	{
		return cast(TabLabel)notebook.getTabLabel(currentPage);
	}

	private IDebugger debugInstance;
	private Builder builder;

	ScrolledFileTree treeview;
	/// The menubar displayed for this window
	@LuaExport("menubar", MethodType.none, "getMenuBarStruct()", RetType.none, MemberType.lightud)
	MenuBar mainMenu;
	/// The notebook subview for this window
	@LuaExport("notebook", MethodType.none, "getNotebookStruct()", RetType.none, MemberType.lightud)
	Notebook notebook;
	/// Reference to self to work better within lua
	@LuaExport("window", MethodType.none, "getWindowStruct()", RetType.none, MemberType.lightud)
	MainWindow self;
	AccelGroup accelGroup;

	private void hookMenuItems()
	{
		void newTab(MenuItem m) {
			addNewSourceEditor(notebook);
			notebook.setCurrentPage(-1);
		}
		auto menuItem = getItem!MenuItem(builder, "menunewfile");
		menuItem.addOnActivate((m)=>newTab(m));
		addAccelerator(menuItem, "<Primary>N", "activate");

		menuItem = getItem!MenuItem(builder, "menuopenfile");
		menuItem.addOnActivate(&openFileMenuItem);
		addAccelerator(menuItem, "<Primary>O", "activate");

		menuItem = getItem!MenuItem(builder, "menuquit");
		menuItem.addOnActivate((m)=>close());

		menuItem = getItem!MenuItem(builder, "menunewwindow");
		menuItem.addOnActivate((m)=>new AppWindow().show());
		addAccelerator(menuItem, "<Primary><Shift>N", "activate");

		menuItem = getItem!MenuItem(builder, "menusavefile");
		menuItem.addOnActivate(&saveFile);
		addAccelerator(menuItem, "<Primary>S", "activate");

		menuItem = getItem!MenuItem(builder, "menusavefileas");
		menuItem.addOnActivate(&saveFileAs);

		addAccelGroup(accelGroup);
	}
	private void addAccelerator(Widget widget, string accelerator, string signal)
	{
		uint keyCode = 0;
		GdkModifierType modifier;
		AccelGroup.acceleratorParse(accelerator, keyCode, modifier);
		widget.addAccelerator(signal, accelGroup, keyCode, modifier, GtkAccelFlags.VISIBLE);
	}
}

