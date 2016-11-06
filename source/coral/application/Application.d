module coral.application.Application;

import coral.window.AppWindow;
import coral.plugin.PluginFramework;

import gtkc.giotypes : GApplicationFlags, GConnectFlags;

import gio.Application : GioApp = Application;
import gtk.Application : GtkApp = Application;

CoralApp coralApplication;

class CoralApp : GtkApp
{
  this()
  {
    super("com.racinettee.coral", GApplicationFlags.HANDLES_OPEN);
    import std.stdio : writeln;
    //addOnOpen((void*, int, string, GioApp) => initPlugins(window));
    addOnActivate((a) => onActivate(a), cast(GConnectFlags)0);
    addOnStartup((a) => initPlugins(window), cast(GConnectFlags)0);
    register(null);
  }
  void onActivate(GioApp app)
  {
    window = new AppWindow;
    addWindow(window);
   //open(null, null);
  }
  AppWindow window;
}