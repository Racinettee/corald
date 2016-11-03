module coral.application.Application;

import gtkc.gtk;
import gtkc.glib;
import gtkc.gio;
import gtkc.gobject;

import gtkc.gtktypes;
import gtkc.glibtypes;
import gtkc.giotypes;
import gtkc.gobjecttypes;

Application coralApplication;

class Application
{
  this()
  {
    app = gtk_application_new("com.racinnettee.coral", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", &onActivate, null);
  }

  void run() @safe
  {
    g_application_run(app, 0, null);
  }

  static int onActivate(GApplication* app)
  {
    import std.stdio : writeln;
    writeln("Activated");
  }
  private GtkApplication* app;
}